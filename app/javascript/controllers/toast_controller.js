import { Controller } from "@hotwired/stimulus"

// Flash notification that auto-dismisses, pauses on hover and can be closed.
export default class extends Controller {
  static values = { duration: { type: Number, default: 5000 } }

  connect() {
    this.element.style.setProperty("--toast-duration", `${this.durationValue}ms`)
    this.remaining = this.durationValue
    this.resume()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  pause() {
    clearTimeout(this.timer)
    this.remaining -= Date.now() - this.startedAt
  }

  resume() {
    this.startedAt = Date.now()
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.dismiss(), Math.max(this.remaining, 0))
  }

  dismiss() {
    clearTimeout(this.timer)
    this.element.classList.add("is-leaving")
    this.element.addEventListener("animationend", () => this.element.remove(), { once: true })
  }
}
