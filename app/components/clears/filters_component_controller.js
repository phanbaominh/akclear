import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  connect() {
    this.formHandler = this.chooseStageId.bind(this);
    this.form = this.element.querySelector("form");
    this.form.addEventListener("formdata", this.formHandler);
  }

  disconnect() {
    this.form.removeEventListener("formdata", this.formHandler);
  }

  chooseStageId(event) {
    const detailedTab = this.element.querySelector(
      'input[value="detailed"]'
    ).checked;
    if (detailedTab && this.element.querySelector("#stage_select")) {
      event.formData.set(
        "clear[stage_id]",
        this.element.querySelector("#stage_select").value
      );
    } else if (this.element.querySelector("#clear_stage_id")) {
      event.formData.set(
        "clear[stage_id]",
        this.element.querySelector("#clear_stage_id").value
      );
    }
  }
}
