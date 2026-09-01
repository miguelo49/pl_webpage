import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  toggle(event) {
    event.preventDefault()

    const isHidden = this.formTarget.classList.contains("hidden")

    document.querySelectorAll("[data-reply-toggle-target='form']").forEach((form) => {
      form.classList.add("hidden")
    })

    if (isHidden) {
      this.formTarget.classList.remove("hidden")
      const textarea = this.formTarget.querySelector("textarea")
      if (textarea) textarea.focus()
    }
  }

  hide() {
    this.formTarget.classList.add("hidden")
  }
}
