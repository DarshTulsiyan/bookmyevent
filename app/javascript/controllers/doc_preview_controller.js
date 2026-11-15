import { Controller } from "@hotwired/stimulus"

// Put on a "View" link: opens the shared preview window instead of a new tab.
// If the preview window isn't on the page, the link behaves normally.
export default class extends Controller {
  static values = { url: String, download: String, name: String, details: String }

  open(event) {
    if (!document.getElementById("doc-preview")) return
    if (event.metaKey || event.ctrlKey || event.shiftKey) return // let users force a new tab

    event.preventDefault()
    window.dispatchEvent(new CustomEvent("doc-preview:open", {
      detail: {
        url: this.urlValue,
        download: this.downloadValue,
        name: this.nameValue,
        details: this.detailsValue
      }
    }))
  }
}
