import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "count", "fill", "console", "activeLog" ]
  static values = { 
    total: Number,
    status: String
  }

  connect() {
    if (this.statusValue === "pending" || this.statusValue === "processing") {
      this.current = 0
      this.logIndex = 0
      this.logs = [
          "[SYSTEM] Inicializando modelo IA...",
          "[PARSER] Analisando texto do resumo...",
          "[ENGINE] Identificando principais conceitos...",
          "[ENGINE] Gerando questões baseadas no contexto...",
          "[VALIDATION] Checando nível de dificuldade...",
          "[FORMAT] Estruturando alternativas e gabarito...",
          "[SYSTEM] Adicionando explicações...",
          "[ENGINE] Finalizando processamento...",
      ]
      
      this.updateProgress()
    } else if (this.statusValue === "done") {
      setTimeout(() => {
        const btn = document.getElementById("view-questions-btn")
        if (btn) btn.click()
        else window.location.href = "/questions"
      }, 2000)
    }
  }

  updateProgress() {
    if (this.statusValue === "done" || this.statusValue === "error") return;

    if (this.current < this.totalValue * 0.9) {
        // Slow increment for realism (takes ~40s to reach 90%)
        const increment = (Math.random() * 0.3) + 0.1
        this.current = Math.min(this.current + increment, this.totalValue * 0.9)
        
        if (this.hasCountTarget) this.countTarget.textContent = Math.floor(this.current)
        if (this.hasFillTarget) this.fillTarget.style.width = `${(this.current / this.totalValue) * 100}%`
    }
        
    // Add log entry
    if (this.logIndex < this.logs.length && Math.random() > 0.3 && this.hasConsoleTarget && this.hasActiveLogTarget) {
        const time = new Date().toLocaleTimeString('en-US', { hour12: false })
        const logDiv = document.createElement('div')
        logDiv.className = 'flex gap-3 text-[#fafafa] opacity-80'
        logDiv.innerHTML = `<span class="opacity-50 text-[#71717a]">${time}</span> <span>${this.logs[this.logIndex]}</span>`
        this.consoleTarget.insertBefore(logDiv, this.activeLogTarget)
        this.logIndex++
        this.consoleTarget.scrollTop = this.consoleTarget.scrollHeight
    }

    // Next tick
    this.timeout = setTimeout(() => this.updateProgress(), 500 + Math.random() * 800)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
