import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["promptInput", "charCount", "modelSelect", "fallbackChain"]
  static values = {
    defaultPrompt: String,
    allModels: Array
  }

  connect() {
    this.updateCharCount()
    this.updateFallbackChain()
  }

  updateCharCount() {
    if (this.hasPromptInputTarget && this.hasCharCountTarget) {
      const length = this.promptInputTarget.value.length
      this.charCountTarget.textContent = `${length.toLocaleString()} caracteres`
    }
  }

  restoreDefaultPrompt(event) {
    if (event) event.preventDefault()
    if (this.hasPromptInputTarget && this.defaultPromptValue) {
      if (confirm("Deseja realmente restaurar o prompt padrão original? Suas alterações não salvas serão substituídas.")) {
        this.promptInputTarget.value = this.defaultPromptValue
        this.updateCharCount()
        this.promptInputTarget.focus()
      }
    }
  }

  updateFallbackChain() {
    if (!this.hasModelSelectTarget || !this.hasFallbackChainTarget || !this.allModelsValue) return

    const selectedModel = this.modelSelectTarget.value
    const remaining = this.allModelsValue.filter(m => m !== selectedModel)

    this.fallbackChainTarget.innerHTML = `
      <div class="flex items-center gap-2 flex-wrap">
        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-semibold bg-[#a78bfa]/20 text-[#a78bfa] border border-[#a78bfa]/30">
          <span class="w-1.5 h-1.5 rounded-full bg-[#a78bfa]"></span>
          1º (Principal): ${selectedModel}
        </span>
        <span class="text-[#71717a] text-xs font-medium">→ Em caso de erro 5xx / 429:</span>
        ${remaining.map((m, idx) => `
          <span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-[#18181b] text-[#a1a1aa] border border-[#27272a]">
            ${idx + 2}º ${m}
          </span>
        `).join('')}
      </div>
    `
  }
}
