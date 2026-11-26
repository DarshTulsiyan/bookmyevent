import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "controls", "previous", "next"]

  connect() {
    this.resizeObserver = new ResizeObserver(() => this.update())
    this.resizeObserver.observe(this.trackTarget)
    this.update()
  }

  disconnect() {
    this.resizeObserver.disconnect()
  }

  previous() {
    this.scroll(-1)
  }

  next() {
    this.scroll(1)
  }

  scroll(direction) {
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.trackTarget.scrollBy({
      left: direction * this.trackTarget.clientWidth,
      behavior: reducedMotion ? "instant" : "smooth"
    })
  }

  update() {
    const track = this.trackTarget
    const maximum = track.scrollWidth - track.clientWidth
    this.controlsTarget.hidden = maximum <= 1
    this.previousTarget.disabled = track.scrollLeft <= 1
    this.nextTarget.disabled = track.scrollLeft >= maximum - 1
  }
}
