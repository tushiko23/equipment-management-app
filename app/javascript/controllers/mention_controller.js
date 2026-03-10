import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mention"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.dismiss()
    }, 3000)
  }

  dismiss() {
    this.element.style.opacity = '0'
    
    setTimeout(() => {
      this.element.remove()
    }, 2000)
  }
}
