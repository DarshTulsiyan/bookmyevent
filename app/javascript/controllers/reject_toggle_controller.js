import { Controller } from "@hotwired/stimulus"

// Progressive enhancement for the compact reject form: shows a single
// "Reject" button first and reveals the reason field only when it's clicked.
// The toggle is created here (not in the HTML) so the page never has two
// "Reject" buttons when JavaScript is off.
export default class extends Controller {
  static targets = ["panel", "reason", "submit"]

  connect() {
    // Turbo's page cache can restore a copy that already has these buttons.
    this.element.querySelectorAll(".reject-toggle, .reject-cancel").forEach((node) => node.remove())

    this.toggleButton = document.createElement("button")
    this.toggleButton.type = "button"
    this.toggleButton.className = "reject-toggle"
    this.toggleButton.textContent = "Reject"
    this.toggleButton.setAttribute("aria-expanded", "false")
    this.toggleButton.addEventListener("click", () => this.expand())
    this.element.prepend(this.toggleButton)

    this.cancelButton = document.createElement("button")
    this.cancelButton.type = "button"
    this.cancelButton.className = "reject-cancel"
    this.cancelButton.textContent = "Cancel"
    this.cancelButton.addEventListener("click", () => this.collapse())
    this.panelTarget.appendChild(this.cancelButton)

    this.submitTarget.value = "Confirm rejection"
    this.collapse(false)
  }

  disconnect() {
    this.toggleButton?.remove()
    this.cancelButton?.remove()
    this.submitTarget.value = "Reject"
    this.element.classList.remove("is-collapsed", "is-open")
  }

  expand() {
    this.element.classList.remove("is-collapsed")
    this.element.classList.add("is-open")
    this.toggleButton.setAttribute("aria-expanded", "true")
    this.reasonTarget.focus()
  }

  collapse(returnFocus = true) {
    this.element.classList.add("is-collapsed")
    this.element.classList.remove("is-open")
    this.toggleButton.setAttribute("aria-expanded", "false")
    if (returnFocus) this.toggleButton.focus()
  }

  keydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.collapse()
    }
  }
}
