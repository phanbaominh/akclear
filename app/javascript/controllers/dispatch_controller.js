import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static values = {
    event: String,
    payload: Object,
    onConnect: Boolean,
  };

  connect() {
    if (this.onConnectValue) {
      this.dp();
    }
  }

  dp() {
    this.dispatch(this.eventValue, { detail: this.payloadValue });
  }
}
