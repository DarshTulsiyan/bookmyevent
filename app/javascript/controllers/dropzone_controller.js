import { Controller } from "@hotwired/stimulus"

const MAX_BYTES = 10 * 1024 * 1024
const ALLOWED = ["application/pdf", "image/jpeg", "image/png"]

// Drag-and-drop styling and instant validation for the authorization upload.
// The server still performs the authoritative type/size checks.
export default class extends Controller {
  static targets = ["input", "title", "hint", "icon"]

  connect() {
    this.defaultTitle = this.titleTarget.innerHTML
    this.defaultHint = this.hintTarget.textContent
  }

  over() {
    this.element.classList.add("is-over")
  }

  leave() {
    this.element.classList.remove("is-over")
  }

  select() {
    const file = this.inputTarget.files[0]
    this.element.classList.remove("has-file", "has-error")
    this.inputTarget.setCustomValidity("")

    if (!file) {
      this.titleTarget.innerHTML = this.defaultTitle
      this.hintTarget.textContent = this.defaultHint
      return
    }

    const size = file.size >= 1024 * 1024
      ? `${(file.size / 1024 / 1024).toFixed(1)} MB`
      : `${Math.max(1, Math.round(file.size / 1024))} KB`

    this.titleTarget.textContent = file.name

    let error = null
    if (file.size > MAX_BYTES) error = `This file is ${size}. The limit is 10 MB.`
    else if (file.type && !ALLOWED.includes(file.type)) error = "Please choose a PDF, JPG, or PNG."

    if (error) {
      this.element.classList.add("has-error")
      this.hintTarget.textContent = error
      this.inputTarget.setCustomValidity(error)
    } else {
      this.element.classList.add("has-file")
      this.hintTarget.textContent = `${size} · ready to submit`
    }
  }
}
