import { Controller } from "@hotwired/stimulus";
// Connects to data-controller="clears--form"
export default class extends Controller {
  removeClasses(event) {
    this.element.classList.remove(...event.params.class.split(" "));
  }
}
