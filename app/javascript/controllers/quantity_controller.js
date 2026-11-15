import { Controller } from "@hotwired/stimulus"

// Ticket quantity steppers with a live order summary.
export default class extends Controller {
  static targets = ["input", "total", "breakdown", "submit"]

  connect() {
    this.update()
  }

  increment(event) {
    this.step(event, 1)
  }

  decrement(event) {
    this.step(event, -1)
  }

  step(event, delta) {
    const input = event.currentTarget.closest(".stepper").querySelector("input")
    const max = Number(input.max || Infinity)
    input.value = Math.min(Math.max((Number(input.value) || 0) + delta, 0), max)
    this.update()
  }

  update() {
    let total = 0
    const parts = []

    this.inputTargets.forEach((input) => {
      const max = Number(input.max || Infinity)
      let value = Math.floor(Number(input.value) || 0)
      if (value < 0) value = 0
      if (value > max) value = max
      if (input.value !== "" && String(value) !== input.value) input.value = value

      input.closest(".qty-row")?.classList.toggle("is-active", value > 0)
      const [minus, plus] = input.closest(".stepper").querySelectorAll("button")
      minus.disabled = value <= 0
      plus.disabled = value >= max

      if (value > 0) parts.push(`${value} × ${input.dataset.tierName}`)
      total += value
    })

    const label = `${total} ${total === 1 ? "ticket" : "tickets"}`
    if (this.totalTarget.textContent !== label) {
      this.totalTarget.textContent = label
      this.totalTarget.classList.remove("bump")
      void this.totalTarget.offsetWidth // restart the animation
      this.totalTarget.classList.add("bump")
    }
    this.breakdownTarget.textContent = parts.length ? parts.join(" · ") : "Use + and − to pick your seats."
    this.submitTarget.disabled = total === 0
  }
}
