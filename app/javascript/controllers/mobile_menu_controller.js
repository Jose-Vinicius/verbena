import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    this.isOpen = !this.isOpen
    if (this.isOpen) {
      this.sidebarTarget.classList.remove("-translate-x-full")
      this.backdropTarget.classList.remove("hidden")
      // Prevent body scroll
      document.body.classList.add("overflow-hidden")
    } else {
      this.sidebarTarget.classList.add("-translate-x-full")
      this.backdropTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }

  close() {
    if (this.isOpen) {
      this.toggle()
    }
  }
}
