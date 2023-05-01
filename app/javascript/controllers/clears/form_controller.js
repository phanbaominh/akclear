import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";
// Connects to data-controller="clears--form"
export default class extends Controller {
  static values = {
    url: String,
    initialUsedOperatorsCount: Number,
  };
  static targets = ["getSubmitButton", "selectOperatorButton"];
  static outlets = ["choices"];
  connect() {
    this.usedOperatorsCount = this.initialUsedOperatorsCountValue || 0;
  }

  updateOperators() {
    this.selectOperatorButtonTarget.click();
  }

  addOperator(event) {
    const formData = new FormData(this.element);
    formData.append(
      `clear[used_operators_attributes][${this.usedOperatorsCount}][operator_id]`,
      event.detail.value
    );
    this.usedOperatorsCount += 1;
    const response = get(this.urlValue, {
      query: formData,
      responseKind: "turbo-stream",
    });
    if (response.ok) this.usedOperatorsCount += 1;
  }

  removeOperator(event) {
    console.log({ removeEvent: event });
    this.choicesOutlet.removeItem(event.detail.operatorId);
    return;

    const formData = new FormData(this.element);
    formData.set(
      `clear[used_operators_attributes][${event.detail.index}][need_to_be_destroyed]`,
      true
    );
    get(this.urlValue, {
      query: formData,
      responseKind: "turbo-stream",
    });
  }
}
