import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  connect() {
    this.eventListener = this.closeDetail.bind(this);
    document.addEventListener("click", this.eventListener);
  }

  disconnect() {
    document.removeEventListener("click", this.eventListener);
  }

  closeDetail(event) {
    if (event.target !== this.element) this.element.removeAttribute("open");
  }
}
