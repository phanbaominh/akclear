import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radioButton"];
  static classes = ["selected"];

  connect() {
    this.radioButtonTargets.forEach((radioButton) => {
      if (radioButton.dataset.checked === "true")
        radioButton.classList.add(...this.selectedClasses);
      else radioButton.classList.remove(...this.selectedClasses);
    });
  }

  select(event) {
    this.radioButtonTargets.forEach((radioButton) => {
      if (radioButton.dataset.value === event.params.value.toString())
        radioButton.classList.add(...this.selectedClasses);
      else radioButton.classList.remove(...this.selectedClasses);
    });
  }
}
