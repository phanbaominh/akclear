import { Controller } from "@hotwired/stimulus";
import Choices from "choices.js";
// Connects to data-controller="clears--form"
export default class extends Controller {
  connect() {
    this.stageSelect = new Choices(this.element.querySelector("select"), {});
  }

  removeItem(itemValue) {
    console.log({ itemValue });
    this.stageSelect.removeActiveItemsByValue(itemValue.toString());
  }
}
