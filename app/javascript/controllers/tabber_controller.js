import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    hiddenClass: "hidden",
  };
  static targets = ["tab", "tabHeader"];

  switchTab(event) {
    this.tabTargets.forEach((tab) => {
      if (tab.dataset.tabName == event.target.value) {
        this.hiddenClassValue.split(" ").forEach((className) => {
          tab.classList.remove(className);
        });
      } else {
        this.hiddenClassValue.split(" ").forEach((className) => {
          tab.classList.add(className);
        });
      }
    });
  }
}
