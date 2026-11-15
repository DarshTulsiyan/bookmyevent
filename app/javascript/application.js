// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Replace the browser's confirm() for data-turbo-confirm with a styled <dialog>.
function confirmWithDialog(message) {
  const dialog = document.getElementById("confirm-dialog")
  if (!dialog || typeof dialog.showModal !== "function") return Promise.resolve(window.confirm(message))

  dialog.querySelector("[data-confirm-message]").textContent = message
  dialog.returnValue = ""
  dialog.showModal()
  dialog.querySelector("[data-confirm-accept]")?.focus()

  return new Promise((resolve) => {
    dialog.addEventListener("close", () => resolve(dialog.returnValue === "confirm"), { once: true })
  })
}

const Turbo = window.Turbo
if (Turbo?.config?.forms) {
  Turbo.config.forms.confirm = confirmWithDialog
} else if (Turbo?.setConfirmMethod) {
  Turbo.setConfirmMethod(confirmWithDialog)
}
