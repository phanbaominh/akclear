import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {}

  emitEvent(event) {
    console.log({ dismissEvent: event });
    this.dispatch("clickDismissOperator", {
      detail: { operatorId: event.params.operatorId },
    });
  }
}
