import { Controller } from "@hotwired/stimulus"

// Document preview window. Esc closes it (native <dialog>), as do the ✕ button
// and a click on the dimmed backdrop.
export default class extends Controller {
  static targets = ["title", "details", "body", "newTab", "download"]

  async open(event) {
    const { url, download, name, details } = event.detail

    this.reset()
    const request = (this.request = Symbol("request"))
    this.titleTarget.textContent = name || "Document"
    this.detailsTarget.textContent = details || ""
    this.newTabTarget.href = url
    this.downloadTarget.href = download
    this.showMessage("loading", "Loading preview…")
    if (!this.element.open) this.element.showModal()

    try {
      const response = await fetch(url, { credentials: "same-origin" })
      if (request !== this.request) return
      if (response.status === 404) {
        return this.showMessage("error", "This file isn't available on this server. It may have been uploaded from another machine's local storage.")
      }
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const blob = await response.blob()
      if (request !== this.request) return
      this.objectUrl = URL.createObjectURL(blob)
      this.render(blob.type)
    } catch (_) {
      if (request === this.request) this.showMessage("error", "The document could not be loaded. Try opening it in a new tab.")
    }
  }

  render(type) {
    this.bodyTarget.replaceChildren()

    if (type.startsWith("image/")) {
      const image = document.createElement("img")
      image.src = this.objectUrl
      image.alt = this.titleTarget.textContent
      image.className = "doc-dialog__image"
      this.bodyTarget.appendChild(image)
    } else if (type === "application/pdf") {
      const frame = document.createElement("iframe")
      frame.src = `${this.objectUrl}#view=FitH`
      frame.title = this.titleTarget.textContent
      frame.className = "doc-dialog__frame"
      this.bodyTarget.appendChild(frame)
    } else {
      this.showMessage("error", "This file type can't be previewed. Use the download button instead.")
    }

    // Keep focus outside the embedded viewer so Esc reaches the dialog.
    this.element.querySelector(".doc-dialog__close")?.focus()
  }

  showMessage(kind, text) {
    const box = document.createElement("div")
    box.className = `doc-dialog__message doc-dialog__message--${kind}`
    if (kind === "loading") box.appendChild(Object.assign(document.createElement("span"), { className: "spinner" }))
    box.appendChild(Object.assign(document.createElement("p"), { textContent: text }))
    this.bodyTarget.replaceChildren(box)
  }

  close() {
    this.element.close()
  }

  backdropClose(event) {
    if (event.target === this.element) this.close()
  }

  reset() {
    this.request = null // ignore any response still in flight
    this.bodyTarget.replaceChildren()
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = null
  }

  disconnect() {
    this.reset()
  }
}
