import { Controller } from "@hotwired/stimulus";
import Choices from "choices.js";
export default class extends Controller {
  static targets = ["stageableButton"];

  connect() {
    this.stageableSelect = new Choices("#stageable__select", {
    });
    new Choices("#operators__select", {
      removeItemButton: true,
    });
  }

  updateStages() {
    this.stageableButtonTarget.click();
  }
}
