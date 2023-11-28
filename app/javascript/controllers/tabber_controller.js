import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    hiddenClass: "hidden",
  };
  static targets = ["tab", "tabHeader"];

  connect() {
    this.tabHeaderTargets[0].click();
  }

  switchTab(event) {
    this.tabTargets.forEach((tab) => {
      if (tab.dataset.tabName == event.target.value) {
        tab.classList.remove(this.hiddenClassValue);
      } else {
        tab.classList.add(this.hiddenClassValue);
      }
    });
  }
}
