import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static values = {
    url: String,
    initialOperators: Array,
  };
  static targets = ["stageableButton"];

  connect() {
    this.operators = this.initialOperatorsValue || [];
    this.element.addEventListener("formdata", this.applyOperatorFilters);
  }

  disconnect() {
    this.element.removeEventListener("formData", this.applyOperatorFilters);
  }
  applyOperatorFilters = (event) => {
    const formData = event.formData;
    this.operators.forEach((operator, index) => {
      formData.append(
        `clear[used_operators_attributes][${index}][operator_id]`,
        operator
      );
    });
  };

  addOperator(event) {
    this.operators.push(event.detail.value);
  }

  applyFilters() {
    this.submit();
  }

  submit() {
    this.element.requestSubmit(
      this.element.querySelector("input[type='submit']")
    );
  }

  removeOperator(event) {
    this.operators = this.operators.filter(
      (value) => value === event.detail.value
    );
  }

  updateStages() {
    this.stageableButtonTarget.click();
  }
}
