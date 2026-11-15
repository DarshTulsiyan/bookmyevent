import { Controller } from "@hotwired/stimulus"

// Show/hide password, strength meter and confirmation match hint.
export default class extends Controller {
  static targets = ["input", "toggle", "meter", "strengthLabel", "confirmation", "matchLabel"]

  toggle(event) {
    const button = event.currentTarget
    const input = button.closest(".password-field").querySelector("input")
    const show = input.type === "password"
    input.type = show ? "text" : "password"
    button.textContent = show ? "Hide" : "Show"
    button.setAttribute("aria-label", show ? "Hide password" : "Show password")
  }

  measure() {
    const value = this.inputTarget.value

    if (this.hasMeterTarget) {
      let score = 0
      if (value.length >= 8) score++
      if (value.length >= 12) score++
      if (/[a-z]/.test(value) && /[A-Z]/.test(value)) score++
      if (/\d/.test(value) && /[^A-Za-z0-9]/.test(value)) score++
      if (value.length < 8) score = Math.min(score, 1)
      if (!value) score = 0

      this.meterTarget.dataset.score = score
      this.strengthLabelTarget.textContent = value
        ? ["Too short", "Weak", "Fair", "Good", "Strong"][score]
        : "At least 8 characters."
    }

    if (this.hasConfirmationTarget && this.hasMatchLabelTarget) {
      const confirmation = this.confirmationTarget.value
      const label = this.matchLabelTarget
      label.classList.remove("is-ok", "is-bad")

      if (!confirmation) {
        label.textContent = ""
      } else if (confirmation === value) {
        label.textContent = "✓ Passwords match"
        label.classList.add("is-ok")
      } else {
        label.textContent = "Passwords do not match yet"
        label.classList.add("is-bad")
      }
    }
  }
}
