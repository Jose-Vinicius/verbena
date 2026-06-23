import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundClose = this.close.bind(this)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
    
    if (!this.menuTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.boundClose)
    } else {
      document.removeEventListener("click", this.boundClose)
    }
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      document.removeEventListener("click", this.boundClose)
    }
  }
}
