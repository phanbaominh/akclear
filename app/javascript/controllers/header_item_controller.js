import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["active"]
  static values = {
    currentPage: Boolean
  }
  connect() {
    if (this.element.currentPageValue) this.element.classList.add(this.activeClass)
  }

  currentPageValueChanged(current, old) {
    if (current) {
      this.element.classList.add(this.activeClass)
    } else {
      this.element.classList.remove(this.activeClass)
    }
  }
}
