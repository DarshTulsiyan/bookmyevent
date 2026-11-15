import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

// Themed date + time picker on top of the native datetime-local field.
// The original input keeps the "YYYY-MM-DDTHH:MM" value Rails expects;
// without JavaScript the native field still works.
export default class extends Controller {
  connect() {
    this.teardown = this.teardown.bind(this)
    document.addEventListener("turbo:before-cache", this.teardown)

    const current = this.element.value ? new Date(this.element.value) : null
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    this.picker = flatpickr(this.element, {
      enableTime: true,
      dateFormat: "Y-m-d\\TH:i",
      altInput: true,
      altFormat: "D, M j, Y \\a\\t h:i K",
      altInputClass: "datetime-input",
      // Don't block editing an event whose saved date is already past.
      minDate: current && current < today ? null : "today",
      minuteIncrement: 5,
      defaultHour: 19,
      disableMobile: true,
      monthSelectorType: "static",
      onReady: (_dates, _str, instance) => this.addPresets(instance),
      onChange: () => this.element.dispatchEvent(new Event("input", { bubbles: true }))
    })

    this.picker.altInput.placeholder = "Pick a date and time"
    this.picker.altInput.required = this.element.required
  }

  disconnect() {
    this.teardown()
  }

  teardown() {
    document.removeEventListener("turbo:before-cache", this.teardown)
    this.picker?.destroy()
    this.picker = null
  }

  // Quick one-click choices under the calendar.
  addPresets(instance) {
    const at = (daysAhead, hour) => {
      const date = new Date()
      date.setDate(date.getDate() + daysAhead)
      date.setHours(hour, 0, 0, 0)
      return date
    }
    const nextSaturday = () => {
      const date = new Date()
      date.setDate(date.getDate() + ((6 - date.getDay() + 7) % 7 || 7))
      date.setHours(19, 0, 0, 0)
      return date
    }

    const presets = [
      [ "Tonight 7 PM", () => at(0, 19) ],
      [ "Tomorrow 7 PM", () => at(1, 19) ],
      [ "Next Sat 7 PM", nextSaturday ],
      [ "In 2 weeks", () => at(14, 19) ]
    ]

    const bar = document.createElement("div")
    bar.className = "flatpickr-presets"
    presets.forEach(([ label, build ]) => {
      const button = document.createElement("button")
      button.type = "button"
      button.textContent = label
      button.addEventListener("click", () => {
        const date = build()
        if (date < new Date()) date.setDate(date.getDate() + 1)
        instance.setDate(date, true)
        instance.close()
      })
      bar.appendChild(button)
    })
    instance.calendarContainer.appendChild(bar)
  }
}
