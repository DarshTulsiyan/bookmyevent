import { Controller } from "@hotwired/stimulus"

// Mobile navigation drawer.
export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.close = this.close.bind(this)
    document.addEventListener("turbo:before-visit", this.close)
  }

  disconnect() {
    document.removeEventListener("turbo:before-visit", this.close)
  }

  toggle() {
    const open = this.element.classList.toggle("is-open")
    this.buttonTarget.setAttribute("aria-expanded", String(open))
  }

  close() {
    this.element.classList.remove("is-open")
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", "false")
  }
}
