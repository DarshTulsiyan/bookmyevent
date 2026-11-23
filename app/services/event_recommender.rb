class EventRecommender
  STOP_WORDS = %w[
    a an and are as at be by for from in is it of on or
    that the this to was we will with you your
  ].freeze

  def initialize(event)
    @event = event
  end

  def call(limit: 4)
    return [] unless @event.publicly_visible?

    events = Event.publicly_visible.includes(:ticket_tiers).to_a
    documents = events.to_h { |event| [ event.id, term_counts(event) ] }

    frequencies = Hash.new(0)
    documents.each_value do |counts|
      counts.each_key { |term| frequencies[term] += 1 }
    end

    vectors = documents.transform_values do |counts|
      tfidf_vector(counts, frequencies, documents.size)
    end

    source = vectors.fetch(@event.id, {})

    events
      .reject { |event| event.id == @event.id || event.seats_left <= 0 }
      .map { |event| [ event, cosine_similarity(source, vectors.fetch(event.id)) ] }
      .select { |_, score| score.positive? }
      .sort_by { |event, score| [ -score, event.starts_at, event.id ] }
      .first(limit)
      .map(&:first)
  end

  private

  def term_counts(event)
    title_terms = tokenize(event.title)

    # Give the title more influence than an equally frequent description term.
    (title_terms + title_terms + tokenize(event.description)).tally
  end

  def tokenize(text)
    text.to_s.downcase.scan(/[[:alnum:]]+/).reject do |term|
      term.length < 2 || STOP_WORDS.include?(term)
    end
  end

  def tfidf_vector(counts, frequencies, document_count)
    counts.to_h do |term, count|
      term_frequency = 1.0 + Math.log(count)
      inverse_document_frequency =
        Math.log((document_count + 1.0) / (frequencies.fetch(term) + 1.0)) + 1.0

      [ term, term_frequency * inverse_document_frequency ]
    end
  end

  def cosine_similarity(left, right)
    return 0.0 if left.empty? || right.empty?

    dot_product = left.sum do |term, weight|
      weight * right.fetch(term, 0.0)
    end

    left_magnitude = Math.sqrt(left.values.sum { |weight| weight**2 })
    right_magnitude = Math.sqrt(right.values.sum { |weight| weight**2 })

    dot_product / (left_magnitude * right_magnitude)
  end
end
