import { Controller } from "@hotwired/stimulus"

// Live event card preview on the "Create an event" page.
export default class extends Controller {
  static targets = [
    "title", "description", "venue", "startsAt", "capacity",
    "titleOut", "descriptionOut", "venueOut", "dateOut", "capacityOut", "month", "day", "weekday"
  ]

  connect() {
    this.update()
  }

  update() {
    if (!this.hasTitleOutTarget) return

    this.titleOutTarget.textContent = this.titleTarget.value.trim() || "Your event title"
    this.venueOutTarget.textContent = this.venueTarget.value.trim() || "Venue"

    const description = this.descriptionTarget.value.trim()
    this.descriptionOutTarget.textContent = description
      ? (description.length > 110 ? `${description.slice(0, 110)}…` : description)
      : "A short description will appear here."

    const capacity = Number(this.capacityTarget.value) || 0
    this.capacityOutTarget.textContent = `${capacity.toLocaleString()} ${capacity === 1 ? "seat" : "seats"}`

    const date = this.startsAtTarget.value ? new Date(this.startsAtTarget.value) : null
    if (date && !Number.isNaN(date.getTime())) {
      this.monthTarget.textContent = date.toLocaleString(undefined, { month: "short" })
      this.dayTarget.textContent = date.getDate()
      this.weekdayTarget.textContent = date.toLocaleString(undefined, { weekday: "short" })
      this.dateOutTarget.textContent = date.toLocaleString(undefined, { dateStyle: "long", timeStyle: "short" })
    } else {
      this.monthTarget.textContent = "TBA"
      this.dayTarget.textContent = "—"
      this.weekdayTarget.textContent = " "
      this.dateOutTarget.textContent = "Pick a date and time"
    }
  }
}
