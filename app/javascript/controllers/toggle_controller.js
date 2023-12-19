import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static targets = ["toggle"];
  static classes = ["on", "off"];

  toggle() {
    console.log(this.toggleTargets);
    this.toggleTargets.forEach((target) => {
      if (target.dataset.toggled == "true") {
        target.classList.remove(...this.onClasses);
        target.classList.add(...this.offClasses);
        target.dataset.toggled = "false";
      } else {
        target.classList.remove(...this.offClasses);
        target.classList.add(...this.onClasses);
        target.dataset.toggled = "true";
      }
    });
  }
}
