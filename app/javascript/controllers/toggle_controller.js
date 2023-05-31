import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static targets = ["toggle"];

  toggle() {
    this.toggleTargets.forEach((target) => {
      if (target.dataset.toggled == "true") {
        target.classList.add("hidden");
        target.dataset.toggled = false;
      } else {
        target.classList.remove("hidden");
        target.dataset.toggled = true;
      }
    });
  }
}
