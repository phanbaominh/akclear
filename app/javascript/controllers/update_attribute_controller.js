import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  setAttr(event) {
    console.log(event.params);
    if (
      !event.params &&
      !event.params.name &&
      !event.params.targetId &&
      !event.params.value
    )
      return;
    document
      .querySelector(`#${event.params.targetId}`)
      .setAttribute(event.params.name, event.params.value);
  }
}
