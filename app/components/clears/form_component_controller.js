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
}
