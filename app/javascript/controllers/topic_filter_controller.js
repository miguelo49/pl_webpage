import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["chip"]
  static values = {
    baseUrl: String,
    selectedIds: Array,
    activeClass: String,
    inactiveClass: String
  }

  selectAll(event) {
    event.preventDefault()
    this.selectedIdsValue = []
    this.updateChipStates()
    this.visit([])
  }

  toggle(event) {
    event.preventDefault()
    const topicId = parseInt(event.currentTarget.dataset.topicId, 10)
    let ids = [...this.selectedIdsValue]

    if (ids.includes(topicId)) {
      ids = ids.filter((id) => id !== topicId)
    } else {
      ids.push(topicId)
    }

    this.selectedIdsValue = ids
    this.updateChipStates()
    this.visit(ids)
  }

  updateChipStates() {
    this.chipTargets.forEach((chip) => {
      const topicId = chip.dataset.topicId
      const active = topicId
        ? this.selectedIdsValue.includes(parseInt(topicId, 10))
        : this.selectedIdsValue.length === 0

      chip.className = active ? this.activeClassValue : this.inactiveClassValue
    })
  }

  visit(topicIds) {
    const url = new URL(this.baseUrlValue, window.location.origin)

    topicIds.forEach((id) => {
      url.searchParams.append("topic_ids[]", id)
    })

    Turbo.visit(url.toString(), { frame: "threads_content" })
  }
}
