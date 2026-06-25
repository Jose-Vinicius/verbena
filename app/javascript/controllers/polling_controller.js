import { Controller } from "@hotwired/stimulus"

// Polling controller que atualiza conteúdo periodicamente.
// - Com url-value: faz fetch da URL e substitui o innerHTML do target "content" (sem piscar)
// - Sem url-value: faz Turbo.visit na página atual (segue redirects naturalmente)
export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 5000 }
  }
  static targets = ["content"]

  connect() {
    this.timer = setInterval(() => this.poll(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  poll() {
    if (this.hasUrlValue) {
      fetch(this.urlValue, {
        headers: { "Accept": "text/html", "X-Requested-With": "XMLHttpRequest" }
      })
        .then(r => r.text())
        .then(html => {
          if (this.hasContentTarget) {
            this.contentTarget.innerHTML = html
          }
        })
        .catch(() => {})
    } else {
      Turbo.visit(window.location.href, { action: "replace" })
    }
  }
}
