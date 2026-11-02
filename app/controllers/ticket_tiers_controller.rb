class TicketTiersController < ApplicationController
  before_action :organizer_only
  before_action :set_event
  before_action :set_ticket_tier, only: %i[update destroy]

  def create
    @ticket_tier = @event.ticket_tiers.build(ticket_tier_params)

    if @ticket_tier.save
      redirect_to edit_event_path(@event),
                  notice: "Ticket tier was successfully created."
    else
      render_event_edit
    end
  end

  def update
    if @ticket_tier.update(ticket_tier_params)
      redirect_to edit_event_path(@event),
                  notice: "Ticket tier was successfully updated."
    else
      render_event_edit
    end
  end

  def destroy
    if @ticket_tier.tickets.exists?
      @ticket_tier.errors.add(
        :base,
        "Cannot delete a ticket tier that has sold tickets."
      )
      render_event_edit
    elsif @ticket_tier.destroy
      redirect_to edit_event_path(@event),
                  notice: "Ticket tier was successfully deleted."
    else
      render_event_edit
    end
  end

  private

  def set_event
    @event = Event.where(organizer_id: current_user.id)
                  .find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path,
                alert: "Event not found or you are not authorized to manage it."
  end

  def set_ticket_tier
    @ticket_tier = @event.ticket_tiers.find(params[:tier_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Ticket tier not found."
  end

  def ticket_tier_params
    params.require(:ticket_tier).permit(:name, :capacity)
  end

  def render_event_edit
    flash.now[:alert] = @ticket_tier.errors.full_messages.to_sentence

    render "events/edit", status: :unprocessable_content
  end
end
