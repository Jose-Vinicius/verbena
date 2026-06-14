import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "content", "icon" ]

  connect() {
    this.isExpanded = false
  }

  toggle(event) {
    if (event) event.preventDefault()
    this.isExpanded = !this.isExpanded
    
    this.element.setAttribute('aria-expanded', this.isExpanded)
    
    if (this.isExpanded) {
      this.contentTarget.classList.add('open')
      this.iconTarget.style.transform = 'rotate(180deg)'
    } else {
      this.contentTarget.classList.remove('open')
      this.iconTarget.style.transform = 'rotate(0deg)'
    }
  }
}
