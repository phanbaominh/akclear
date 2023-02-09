import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static values = {
    url: String,
  };
  static targets = ["getSubmitButton"];
  connect() {
    console.log("FORM!");
    console.log(this.urlValue);
  }

  addOperator(event) {
    const formData = new FormData(this.element);
    formData.append("clear[used_operators_attributes][0][operator_id]", "1");
    const queryString = new URLSearchParams(formData).toString();
    console.log({ queryString, hastarget: this.hasGetSubmitButtonTarget });
    console.log(this.getSubmitButtonTarget);
    this.getSubmitButtonTarget.setAttribute(
      "href",
      `${this.urlValue}?${queryString}`
    );
    this.getSubmitButtonTarget.click();
  }
}
