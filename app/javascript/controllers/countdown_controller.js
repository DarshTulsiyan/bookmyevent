import { Controller } from "@hotwired/stimulus"

// Live "starts in" countdown.
export default class extends Controller {
  static targets = ["output"]
  static values = { at: String }

  connect() {
    this.startsAt = new Date(this.atValue).getTime()
    if (Number.isNaN(this.startsAt)) return

    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const diff = this.startsAt - Date.now()
    if (diff <= 0) {
      this.outputTarget.textContent = "Happening now"
      clearInterval(this.timer)
      return
    }

    const total = Math.floor(diff / 1000)
    const days = Math.floor(total / 86400)
    const hours = Math.floor((total % 86400) / 3600)
    const minutes = Math.floor((total % 3600) / 60)
    const seconds = total % 60
    const pad = (n) => String(n).padStart(2, "0")

    this.outputTarget.textContent = days > 0
      ? `Starts in ${days}d ${pad(hours)}h ${pad(minutes)}m`
      : `Starts in ${pad(hours)}:${pad(minutes)}:${pad(seconds)}`
  }
}
