import { Controller } from "@hotwired/stimulus"

// Shows how many seats remain unassigned as the organizer types a tier capacity.
export default class extends Controller {
  static targets = ["input", "hint"]
  static values = { remaining: Number }

  check() {
    const requested = Number(this.inputTarget.value) || 0
    const left = this.remainingValue - requested
    const seats = (n) => `${n} ${Math.abs(n) === 1 ? "seat" : "seats"}`

    this.hintTarget.classList.toggle("is-over", left < 0)
    this.hintTarget.classList.toggle("is-ok", requested > 0 && left >= 0)

    if (requested === 0) {
      this.hintTarget.textContent = `${seats(Math.max(this.remainingValue, 0))} still unassigned.`
    } else if (left < 0) {
      this.hintTarget.textContent = `That is ${seats(-left)} over the event's total capacity.`
    } else {
      this.hintTarget.textContent = `Looks good: ${seats(left)} will remain unassigned.`
    }
  }
}
