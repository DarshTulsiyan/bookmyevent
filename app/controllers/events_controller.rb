class EventsController < ApplicationController
  before_action :organizer_only, only: %i[new create edit update submit_for_review]
  before_action :admin_only, only: %i[approve reject]
  before_action :own_event_only, only: %i[edit update submit_for_review]

  def index
    @events = Event.publicly_visible.includes(:ticket_tiers)
  end

  def show
    @event = Event.find_by(id: params[:id])
    return head :not_found unless @event&.visible_to?(current_user)

    @ticket_tiers = @event.ticket_tiers.order(:id)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.organizer = current_user
    @event.status = :draft

    if @event.save
      redirect_to edit_event_path(@event),
                  notice: "Event created. Add ticket tiers below.",
                  status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to edit_event_path(@event),
                  notice: "Event updated",
                  status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    event = Event.find_by(id: params[:id])
    return head :not_found unless event

    if event.approve
      redirect_to admin_pending_events_path,
                  notice: "Event approved and published.",
                  status: :see_other
    else
      redirect_to admin_pending_events_path,
                  alert: event.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  def reject
    event = Event.find_by(id: params[:id])
    return head :not_found unless event

    if event.reject(reason: params[:rejection_reason])
      redirect_to admin_pending_events_path,
                  notice: "Event rejected.",
                  status: :see_other
    else
      redirect_to admin_pending_events_path,
                  alert: event.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  def submit_for_review
    unless @event.submittable_for_review?
      return redirect_to edit_event_path(@event),
                         alert: "Only draft or rejected events can be submitted.",
                         status: :see_other
    end

    upload = params[:authorization_document]
    content_type = authorization_document_type(upload)
    unless content_type
      return redirect_to edit_event_path(@event),
                         alert: "Upload a PDF, JPG, or PNG up to 10 MB.",
                         status: :see_other
    end

    blob = ActiveStorage::Blob.build_after_unfurling(
      io: upload.tempfile,
      filename: upload.original_filename,
      content_type: content_type,
      identify: false
    )
    blob.save!
    unless upload_review_document(blob, upload.tempfile)
      return redirect_to edit_event_path(@event),
                         alert: "The document could not be uploaded. Please try again.",
                         status: :see_other
    end

    if @event.submit_for_review(blob)
      redirect_to edit_event_path(@event),
                  notice: "Event submitted for review.",
                  status: :see_other
    else
      redirect_to edit_event_path(@event),
                  alert: @event.errors.full_messages.to_sentence,
                  status: :see_other
    end
  ensure
    purge_unattached_review_document(blob) if blob&.persisted?
  end

  def authorization_document
    event = Event.find_by(id: params[:id])
    user = current_user

    return head :not_found unless event && user
    return head :not_found unless user.admin? || event.organizer_id == user.id

    document = event.authorization_document
    return head :not_found unless document.attached?

    data = document.download
    response.headers["Cache-Control"] = "private, no-store"

    send_data data,
              filename: document.filename.to_s,
              type: "application/octet-stream",
              disposition: "attachment"
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end

  private

  def authorization_document_type(upload)
    return unless upload.is_a?(ActionDispatch::Http::UploadedFile)
    return unless upload.size.between?(1, 10.megabytes)

    type = Marcel::MimeType.for(upload.tempfile)
    upload.tempfile.rewind
    type if %w[application/pdf image/jpeg image/png].include?(type)
  end

  def upload_review_document(blob, io)
    blob.upload_without_unfurling(io)
    true
  rescue StandardError => error
    Rails.error.report(error)
    false
  end

  def purge_unattached_review_document(blob)
    blob.purge unless blob.attachments.exists?
  rescue StandardError => error
    Rails.error.report(error)
  end

  def own_event_only
    @event = Event.find_by(id: params[:id])

    head :not_found if @event.nil? || @event.organizer != current_user
  end

  # organizer and status are never taken from the form.
  def event_params
    params.require(:event).permit(
      :title,
      :description,
      :venue,
      :starts_at,
      :total_capacity
    )
  end
end
