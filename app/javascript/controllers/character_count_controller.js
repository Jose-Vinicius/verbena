import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "counter" ]
  static values = { max: { type: Number, default: 10000 } }

  connect() {
    this.update()
  }

  update() {
    const count = this.inputTarget.value.length
    this.counterTarget.textContent = `${count} / ${this.maxValue} chars`
    
    if (count > this.maxValue) {
      this.counterTarget.classList.add("text-[#ef4444]")
      this.counterTarget.classList.remove("text-[#a1a1aa]")
    } else {
      this.counterTarget.classList.remove("text-[#ef4444]")
      this.counterTarget.classList.add("text-[#a1a1aa]")
    }
  }
}
