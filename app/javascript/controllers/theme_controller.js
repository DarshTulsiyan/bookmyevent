import { Controller } from "@hotwired/stimulus"

// Light/dark toggle. Remembers the choice; otherwise follows the OS setting.
export default class extends Controller {
  toggle() {
    const root = document.documentElement
    const current = root.dataset.theme ||
      (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
    const next = current === "dark" ? "light" : "dark"

    root.dataset.theme = next
    try { localStorage.setItem("bme-theme", next) } catch (_) {}
  }
}
