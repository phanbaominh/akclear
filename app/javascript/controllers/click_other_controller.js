import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["clickable"];

  clickOther() {
    this.clickableTarget.click();
  }
}
