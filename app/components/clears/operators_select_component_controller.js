import { Controller } from "@hotwired/stimulus";
import Choices from "choices.js";
import "choices.js/public/assets/styles/choices.min.css";
// Connects to data-controller="clears--operators-select-component"
export default class extends Controller {
  connect() {
    const multipleCancelButton = new Choices("#clear-form__operators-select", {
      allowHTML: true,
      removeItemButton: true,
    });
  }

  addOperator(event) {
    console.log({ event });
    const link = document.getElementById("cool-link");
    link.setAttribute("href", "/operators/1");
    link.click();
  }
}
