// Configure your import map in config/importmap.rb. Read more: https://guides.rubyonrails.org/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const setupConfirmModal = () => {
  const turbo = window.Turbo
  if (!turbo) return

  turbo.config.forms.confirm = (message, element, submitter) => {
    const modal = document.getElementById("confirm-modal")
    const titleEl = document.getElementById("confirm-modal-title")
    const messageEl = document.getElementById("confirm-modal-message")
    const acceptBtn = document.getElementById("confirm-modal-accept")
    const cancelBtn = document.getElementById("confirm-modal-cancel")

    if (!modal || !messageEl || !acceptBtn || !cancelBtn) {
      return Promise.resolve(window.confirm(message))
    }

    const title = submitter?.dataset?.turboConfirmTitle || element?.dataset?.turboConfirmTitle || "Confirmar ação"
    const confirmLabel = submitter?.dataset?.turboConfirmButton || element?.dataset?.turboConfirmButton || "Confirmar"

    if (titleEl) titleEl.textContent = title
    messageEl.textContent = message
    acceptBtn.textContent = confirmLabel

    modal.classList.remove("hidden")
    modal.classList.add("flex")
    cancelBtn.focus()

    return new Promise((resolve) => {
      const cleanup = (result) => {
        modal.classList.add("hidden")
        modal.classList.remove("flex")
        acceptBtn.removeEventListener("click", onAccept)
        cancelBtn.removeEventListener("click", onCancel)
        modal.removeEventListener("click", onBackdropClick)
        document.removeEventListener("keydown", onKeyDown)
        resolve(result)
      }

      const onAccept = () => cleanup(true)
      const onCancel = () => cleanup(false)
      const onBackdropClick = (event) => {
        if (event.target === modal) cleanup(false)
      }
      const onKeyDown = (event) => {
        if (event.key === "Escape") cleanup(false)
      }

      acceptBtn.addEventListener("click", onAccept)
      cancelBtn.addEventListener("click", onCancel)
      modal.addEventListener("click", onBackdropClick)
      document.addEventListener("keydown", onKeyDown)
    })
  }
}

setupConfirmModal()
