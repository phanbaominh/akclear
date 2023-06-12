import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static targets = ["toggle"];
  static classes = ["on", "off"];

  toggle() {
    console.log(this.toggle)
    if (this.toggleTarget.dataset.toggled == "true") {
      this.toggleTarget.classList.remove(...this.onClasses);
      this.toggleTarget.classList.add(...this.offClasses);
      this.toggleTarget.dataset.toggled = "false";
    } else {
      this.toggleTarget.classList.remove(...this.offClasses);
      this.toggleTarget.classList.add(...this.onClasses);
      this.toggleTarget.dataset.toggled = "true";
    }
  }
}
