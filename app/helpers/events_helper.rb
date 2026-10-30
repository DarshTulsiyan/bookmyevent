module EventsHelper
  STATUS_LABELS = {
    "pending" => "Pending approval",
    "approved" => "Approved",
    "rejected" => "Rejected"
  }.freeze

  def event_status_badge(event)
    tag.span STATUS_LABELS.fetch(event.status),
             class: "badge badge-#{event.status}"
  end
end
