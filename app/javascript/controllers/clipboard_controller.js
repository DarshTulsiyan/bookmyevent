import { Controller } from "@hotwired/stimulus"

// Copy a Ticket ID to the clipboard with quick feedback.
export default class extends Controller {
  static targets = ["label"]
  static values = { text: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textValue)
      this.flash("Copied!")
    } catch (_) {
      this.flash("Press Ctrl+C")
    }
  }

  flash(message) {
    this.element.classList.add("is-copied")
    this.labelTarget.textContent = message
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.element.classList.remove("is-copied")
      this.labelTarget.textContent = "Copy"
    }, 1600)
  }
}
