import { Controller } from "@hotwired/stimulus"

// Generic chip + search filter, with optional sorting.
// Items declare data-filter-keys (space separated), optionally data-filter-text
// for the search haystack, and data-sort-<key> values for the sort select
// (option values look like "starts:asc").
export default class extends Controller {
  static targets = ["item", "button", "query", "empty", "sort", "list"]

  connect() {
    this.active = "all"
  }

  select(event) {
    this.active = event.params.value
    this.buttonTargets.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.filterValueParam === this.active))
    })
    this.apply()
  }

  apply() {
    const query = this.hasQueryTarget ? this.queryTarget.value.trim().toLowerCase() : ""
    let visible = 0

    this.itemTargets.forEach((item) => {
      const keys = (item.dataset.filterKeys || "").split(" ")
      const text = (item.dataset.filterText || item.textContent).toLowerCase()
      const match = (this.active === "all" || keys.includes(this.active)) && (!query || text.includes(query))
      item.hidden = !match
      if (match) visible++
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible > 0
  }

  sort() {
    if (!this.hasSortTarget || !this.hasListTarget) return

    const [ key, direction ] = this.sortTarget.value.split(":")
    const attribute = `sort${key.charAt(0).toUpperCase()}${key.slice(1)}`
    const factor = direction === "desc" ? -1 : 1

    this.itemTargets
      .sort((a, b) => {
        const x = a.dataset[attribute] ?? ""
        const y = b.dataset[attribute] ?? ""
        const numeric = x !== "" && y !== "" && !Number.isNaN(Number(x)) && !Number.isNaN(Number(y))
        return factor * (numeric ? Number(x) - Number(y) : x.localeCompare(y))
      })
      .forEach((item) => this.listTarget.appendChild(item))
  }
}
