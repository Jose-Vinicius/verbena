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
          "[SYSTEM] Initializing NLP pipeline... OK",
          "[PARSER] Extracting context from source documents... OK",
          "[ENGINE] Analyzing semantic nodes (batch 1)... OK",
          "[ENGINE] Generating item 10...",
          "[VALIDATION] Checking cognitive load balance... OK",
          "[ENGINE] Generating item 15...",
          "[FORMAT] Applying syntax highlighting...",
          "[SYSTEM] Optimizing token usage...",
          "[PARSER] Cross-referencing index terms...",
          "[SYSTEM] Finalizing batch...",
      ]
      
      this.updateProgress()
    }
  }

  updateProgress() {
    if (this.statusValue === "done" || this.statusValue === "error") return;

    if (this.current < this.totalValue * 0.9) {
        // Random increment to simulate real processing
        const increment = Math.floor(Math.random() * 3) + 1
        this.current = Math.min(this.current + increment, this.totalValue * 0.9)
        
        // Update visual counter and bar
        if (this.hasCountTarget) this.countTarget.textContent = Math.floor(this.current)
        if (this.hasFillTarget) this.fillTarget.style.width = `${(this.current / this.totalValue) * 100}%`
        
        // Add log entry
        if (this.logIndex < this.logs.length && Math.random() > 0.4 && this.hasConsoleTarget && this.hasActiveLogTarget) {
            const time = new Date().toLocaleTimeString('en-US', { hour12: false })
            const logDiv = document.createElement('div')
            logDiv.className = 'flex gap-3 text-[#fafafa] opacity-80'
            logDiv.innerHTML = `<span class="opacity-50 text-[#71717a]">${time}</span> <span>${this.logs[this.logIndex]}</span>`
            this.consoleTarget.insertBefore(logDiv, this.activeLogTarget)
            this.logIndex++
            this.consoleTarget.scrollTop = this.consoleTarget.scrollHeight
        }

        // Next tick
        this.timeout = setTimeout(() => this.updateProgress(), 400 + Math.random() * 600)
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
