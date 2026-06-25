import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "icon", "label"]

  copy() {
    const text = this.sourceTarget.value
    navigator.clipboard.writeText(text).then(() => {
      this.iconTarget.textContent = "check"
      this.labelTarget.textContent = "Copiado!"
      
      setTimeout(() => {
        this.iconTarget.textContent = "content_copy"
        this.labelTarget.textContent = "Copiar"
      }, 2000)
    })
  }
}
