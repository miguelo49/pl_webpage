import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button", "feedback" ]
  static values = {
    url: String,
    title: String,
    text: String
  }

  async share(event) {
    event.preventDefault()

    const shareData = {
      title: this.titleValue,
      text: this.hasTextValue ? this.textValue : this.titleValue,
      url: this.urlValue
    }

    if (navigator.share) {
      try {
        await navigator.share(shareData)
        return
      } catch (error) {
        if (error.name === "AbortError") return
      }
    }

    await this.copyToClipboard(this.urlValue)
    this.showFeedback("Enlace copiado")
  }

  async copyToClipboard(url) {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(url)
      return
    }

    const input = document.createElement("textarea")
    input.value = url
    input.setAttribute("readonly", "")
    input.style.position = "absolute"
    input.style.left = "-9999px"
    document.body.appendChild(input)
    input.select()
    document.execCommand("copy")
    document.body.removeChild(input)
  }

  showFeedback(message) {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.textContent = message
    this.feedbackTarget.classList.remove("hidden")

    window.setTimeout(() => {
      this.feedbackTarget.classList.add("hidden")
    }, 2000)
  }
}
