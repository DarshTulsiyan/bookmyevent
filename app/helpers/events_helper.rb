module EventsHelper
  STATUS_LABELS = {
    "draft" => "Draft",
    "pending" => "Pending Review",
    "approved" => "Approved",
    "rejected" => "Rejected"
  }.freeze

  def event_status_badge(event)
    tag.span STATUS_LABELS.fetch(event.status),
             class: "badge badge-#{event.status}"
  end

  # Curated hues that look good as white-text gradients (violet, indigo, pink, teal…).
  EVENT_HUES = [ 252, 285, 330, 205, 345, 228, 175, 265, 12, 310 ].freeze

  # A stable accent hue per event so every card gets its own gradient.
  def event_hue(event)
    EVENT_HUES[event.id.to_i % EVENT_HUES.size]
  end

  def event_date_tile(event, css: nil)
    tag.div(class: [ "date-tile", css ].compact.join(" "), aria: { hidden: true }) do
      safe_join([
        tag.span(event.starts_at.strftime("%b"), class: "date-tile__month"),
        tag.span(event.starts_at.day, class: "date-tile__day"),
        tag.span(event.starts_at.strftime("%a"), class: "date-tile__weekday")
      ])
    end
  end

  def tier_stats(tiers)
    capacity = tiers.sum { |tier| tier.capacity.to_i }
    sold = tiers.sum { |tier| tier.tickets_sold.to_i }
    percent = capacity.positive? ? ((sold * 100.0) / capacity).round : 0

    { capacity: capacity, sold: sold, left: capacity - sold, percent: percent }
  end

  # Saved (database) tier numbers for the organizer's edit page.
  def tier_summary(event)
    tiers = TicketTier.where(event_id: event.id).order(:id).to_a
    total = event.total_capacity_in_database.to_i
    allocated = tiers.sum(&:capacity)

    {
      tiers: tiers,
      total: total,
      allocated: allocated,
      unassigned: total - allocated,
      allocation_percent: total.positive? ? (allocated * 100.0 / total) : 0,
      stats: tier_stats(tiers)
    }
  end

  def availability_chip(left, capacity)
    if capacity.zero?
      tag.span "Tickets soon", class: "chip chip--neutral"
    elsif left.zero?
      tag.span "Sold out", class: "chip chip--danger"
    elsif left * 5 <= capacity
      tag.span "Almost gone", class: "chip chip--warning"
    else
      tag.span "On sale", class: "chip chip--success"
    end
  end

  def meter(percent, label:)
    percent = percent.to_i.clamp(0, 100)
    tone = if percent >= 100 then "meter--full"
    elsif percent >= 80 then "meter--hot"
    end

    tag.div(class: [ "meter", tone ].compact.join(" "),
            role: "progressbar",
            aria: { label: label, valuenow: percent, valuemin: 0, valuemax: 100 }) do
      tag.span(class: "meter__fill", style: "width: #{percent}%")
    end
  end

  def relative_start(event)
    return "Happening now" unless event.starts_at.future?

    "Starts in #{time_ago_in_words(event.starts_at)}"
  end
end
