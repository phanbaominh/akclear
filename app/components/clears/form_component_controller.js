import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  highlight({ detail: { operatorId } }) {
    this.element.querySelectorAll(".operators__card").forEach((card) => {
      card.classList.remove("outline", "outline-primary");
      if (card.dataset.operatorId == operatorId) {
        card.classList.add("outline", "outline-primary");
      }
    });
  }

  closeForm() {
    this.highlight({ detail: { operatorId: null } });
    this.appendNewButton();
    this.removeForm();
  }

  removeForm() {
    this.element.querySelector("#operators__form_container > form").remove();
  }

  appendNewButton() {
    if (
      this.element.querySelector(
        "#operators__list #operators__new_operator_btn"
      )
    )
      return;
    const addButton = this.element
      .querySelector("#operators__new_operator_btn_template")
      .content.cloneNode(true);
    this.element.querySelector("#operators__list").appendChild(addButton);
  }
}
