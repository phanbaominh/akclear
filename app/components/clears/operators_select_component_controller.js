import { Controller } from "@hotwired/stimulus";
import Choices from "choices.js";
import "choices.js/public/assets/styles/choices.min.css";
// Connects to data-controller="clears--operators-select-component"
export default class extends Controller {
  static values = {
    operators: Array,
  };
  connect() {
    this.choicesElement = new Choices("#clear-form__operators-select", {
      allowHTML: true,
      removeItemButton: true,
      placeholderValue: "Add operator to squad",
    });
    this.choicesElement.setChoices(this.operatorsValue);
  }
}
