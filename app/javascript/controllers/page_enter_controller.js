import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.classList.remove("animate-fade-in-up")
    void this.element.offsetWidth
    this.element.classList.add("animate-fade-in-up")
  }
}
