import { Controller } from "@hotwired/stimulus"

// Live search, sort and grid/list layout for the public events page.
export default class extends Controller {
  static targets = ["card", "list", "query", "sort", "count", "empty", "viewButton"]

  connect() {
    let view = "grid"
    try { view = localStorage.getItem("bme-events-view") || "grid" } catch (_) {}
    this.applyView(view)
  }

  apply() {
    const query = this.queryTarget.value.trim().toLowerCase()
    let visible = 0

    this.cardTargets.forEach((card) => {
      const match = !query || `${card.dataset.title} ${card.dataset.venue}`.includes(query)
      card.hidden = !match
      if (match) visible++
    })

    this.sortCards()
    this.countTarget.textContent = `${visible} ${visible === 1 ? "event" : "events"}`
    this.emptyTarget.hidden = visible !== 0
  }

  sortCards() {
    const compare = {
      seats: (a, b) => Number(b.dataset.seats) - Number(a.dataset.seats),
      title: (a, b) => a.dataset.title.localeCompare(b.dataset.title),
      date: (a, b) => Number(a.dataset.starts) - Number(b.dataset.starts)
    }[this.sortTarget.value]

    this.cardTargets.sort(compare).forEach((card) => this.listTarget.appendChild(card))
  }

  setView(event) {
    const view = event.currentTarget.dataset.view
    this.applyView(view)
    try { localStorage.setItem("bme-events-view", view) } catch (_) {}
  }

  applyView(view) {
    this.listTarget.dataset.view = view
    this.viewButtonTargets.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.view === view))
    })
  }
}
