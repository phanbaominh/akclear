import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static targets = ["update"];

  setAttr(event) {
    const target = this.target(event);
    if (
      !event.params ||
      !event.params.name ||
      !target ||
      event.params.value === undefined
    )
      return;
    target[event.params.name] = event.params.value;
  }

  setAttrOnSelect(event) {
    if (!event.params || !event.params.name || event.params.value === undefined)
      return;
    if (!event.detail.value && event.params.blankValue !== undefined) {
      event.params.value = event.params.blankValue;
    }
    this.setAttr(event);
  }

  target(event) {
    return (
      (this.hasUpdateTarget && this.updateTarget) ||
      document.querySelector(event.params.targetCss)
    );
  }
}
