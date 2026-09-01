import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["sentinel"]

  static values = {
    url: String,
    page: { type: Number, default: 1 },
    hasMore: { type: Boolean, default: true },
    loading: { type: Boolean, default: false }
  }

  connect() {
    if (!this.hasMoreValue || !this.hasSentinelTarget) return

    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      { rootMargin: "200px" }
    )

    this.observeSentinel()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  observeSentinel() {
    if (!this.observer || !this.hasSentinelTarget) return

    this.observer.disconnect()
    this.observer.observe(this.sentinelTarget)
  }

  async handleIntersection(entries) {
    const visible = entries.some((entry) => entry.isIntersecting)
    if (!visible || !this.hasMoreValue || this.loadingValue) return

    await this.loadNextPage()
  }

  async loadNextPage() {
    if (this.loadingValue || !this.hasMoreValue) return

    this.loadingValue = true
    const nextPage = this.pageValue + 1
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("page", String(nextPage))

    try {
      const response = await fetch(url.toString(), {
        headers: {
          Accept: "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        },
        credentials: "same-origin"
      })

      if (response.status === 204) {
        this.hasMoreValue = false
        this.removeSentinel()
        return
      }

      if (!response.ok) return

      const html = await response.text()
      if (!html.trim()) {
        this.hasMoreValue = false
        this.removeSentinel()
        return
      }

      Turbo.renderStreamMessage(html)
      this.pageValue = nextPage

      if (!this.hasSentinelTarget) {
        this.hasMoreValue = false
      } else {
        this.observeSentinel()
      }
    } finally {
      this.loadingValue = false

      if (this.hasMoreValue && this.hasSentinelTarget) {
        this.loadIfSentinelVisible()
      }
    }
  }

  loadIfSentinelVisible() {
    const rect = this.sentinelTarget.getBoundingClientRect()
    const visible = rect.top <= window.innerHeight + 200

    if (visible) {
      this.loadNextPage()
    }
  }

  removeSentinel() {
    if (this.hasSentinelTarget) {
      this.sentinelTarget.remove()
    }
  }
}
