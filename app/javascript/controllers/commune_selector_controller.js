import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "regionSelect", "communeSelect" ]
  static values = {
    url: String,
    selectedCommune: Number
  }

  connect() {
    if (this.regionSelectTarget.value) {
      this.loadCommunes()
    } else {
      this.resetCommuneSelect()
    }
  }

  regionChanged() {
    this.selectedCommuneValue = null
    this.loadCommunes()
  }

  async loadCommunes() {
    const regionId = this.regionSelectTarget.value

    if (!regionId) {
      this.resetCommuneSelect()
      return
    }

    const url = this.urlValue.replace("REGION_ID", regionId)

    try {
      const response = await fetch(url, {
        headers: { Accept: "application/json" }
      })

      if (!response.ok) return

      const communes = await response.json()
      this.updateCommuneSelect(communes)
    } catch (_error) {
      this.resetCommuneSelect()
    }
  }

  resetCommuneSelect() {
    this.communeSelectTarget.innerHTML = ""
    this.communeSelectTarget.add(new Option("Selecciona una comuna", ""))
    this.communeSelectTarget.value = ""
    this.communeSelectTarget.disabled = true
  }

  updateCommuneSelect(communes) {
    const selectedId = this.hasSelectedCommuneValue ? this.selectedCommuneValue : null

    this.communeSelectTarget.innerHTML = ""
    this.communeSelectTarget.add(new Option("Selecciona una comuna", ""))

    communes.forEach((commune) => {
      const option = new Option(commune.name, commune.id)
      if (selectedId && commune.id === selectedId) {
        option.selected = true
      }
      this.communeSelectTarget.add(option)
    })

    this.communeSelectTarget.disabled = false
  }
}
