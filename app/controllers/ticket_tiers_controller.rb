class TicketTiersController < ApplicationController
  before_action :organizer_only
  before_action :set_event
  before_action :set_ticket_tier, only: %i[update destroy]

  def create
    @ticket_tier = @event.ticket_tiers.build(ticket_tier_params)

    if @ticket_tier.save
      respond_with_tiers("Ticket tier was successfully created.", highlight: @ticket_tier)
    else
      render_event_edit
    end
  end

  def update
    if @ticket_tier.update(ticket_tier_params)
      respond_with_tiers("Ticket tier was successfully updated.", highlight: @ticket_tier)
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
      respond_with_tiers("Ticket tier was successfully deleted.")
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

  # Turbo (JS) requests get the tier panel updated in place; plain HTML
  # requests keep the original redirect behaviour.
  def respond_with_tiers(message, highlight: nil)
    respond_to do |format|
      format.html do
        redirect_to edit_event_path(@event), notice: message
      end
      format.turbo_stream do
        @highlight_tier_id = highlight&.id
        @ticket_tier = nil
        render turbo_stream: tier_streams(:notice, message)
      end
    end
  end

  def render_event_edit
    message = @ticket_tier.errors.full_messages.to_sentence

    respond_to do |format|
      format.html do
        flash.now[:alert] = message
        render "events/edit", status: :unprocessable_content
      end
      format.turbo_stream do
        render turbo_stream: tier_streams(:alert, message),
               status: :unprocessable_content
      end
    end
  end

  def tier_streams(kind, message)
    [
      turbo_stream.replace("ticket-tiers", partial: "events/tiers_panel"),
      turbo_stream.replace("capacity-card", partial: "events/capacity_card"),
      turbo_stream.replace("publish-steps", partial: "events/steps"),
      turbo_stream.append("toasts", partial: "shared/toast", locals: { kind: kind, message: message })
    ]
  end
end
