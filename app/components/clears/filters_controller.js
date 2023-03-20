import { Controller } from "@hotwired/stimulus";
import Choices from "choices.js";
export default class extends Controller {
  static targets = ["stageableButton"];

  connect() {
    this.choicesElement = new Choices("#stageable__select", {
      allowHTML: true,
    });
    this.choicesElement = new Choices("#operators__select", {
      allowHTML: true,
      removeItemButton: true,
    });
  }

  updateStages() {
    this.stageableButtonTarget.click();
  }
}
