class EventsController < ApplicationController
  before_action :organizer_only, only: %i[new create edit update]
  before_action :admin_only, only: %i[approve reject]
  before_action :own_event_only, only: %i[edit update]

  def index
    @events = Event.approved.upcoming
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
    @event.status = :pending

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

    if event.reject
      redirect_to admin_pending_events_path,
                  notice: "Event rejected.",
                  status: :see_other
    else
      redirect_to admin_pending_events_path,
                  alert: event.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  private

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
