import { Controller } from "@hotwired/stimulus";
import "choices.js/public/assets/styles/choices.min.css";
import Choices from "choices.js";
// Connects to data-controller="clears--form"

export default class extends Controller {
  static values = {
    choicesOptions: Object,
  };

  connect() {
    this.stageSelect = new Choices(
      this.element.querySelector("select"),
      this.choicesOptionsValue || {}
    );
  }

  disconnect() {
    const value = this.stageSelect.getValue(true);
    this.stageSelect.destroy();
    this.element.querySelector("select").value = value;
  }

  removeItem(itemValue) {
    this.stageSelect.removeActiveItemsByValue(itemValue.toString());
  }
}
