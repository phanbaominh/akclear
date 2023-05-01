import { Controller } from "@hotwired/stimulus";
import "choices.js/public/assets/styles/choices.min.css";
// Connects to data-controller="clears--operators-select-component"
export default class extends Controller {
  static targets = ["turboTrigger"];

  appendOperator() {
    this.turboTriggerTarget.click();
  }
}
