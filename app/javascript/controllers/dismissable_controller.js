import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static values = {
    useTimeout: true,
    delay: 3000,
  };

  connect() {
    if (this.useTimeoutValue)
      this.timeout = setTimeout(() => {
        this.dismiss();
      }, this.delayValue);
  }

  disconnect() {
    if (this.useTimeout) clearTimeout(this.timeout);
  }

  dismiss() {
    this.element.remove();
  }
}
