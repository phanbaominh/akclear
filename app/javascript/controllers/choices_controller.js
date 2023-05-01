import { Controller } from "@hotwired/stimulus";
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

  removeItem(itemValue) {
    console.log({ itemValue });
    this.stageSelect.removeActiveItemsByValue(itemValue.toString());
  }
}
