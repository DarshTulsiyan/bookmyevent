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
end
