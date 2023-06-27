import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["mode", "list"];
  static values = { isGrid: Boolean };

  connect() {
    this.isGrid = true;
  }

  toggle() {
    this.isGrid = !this.isGrid;
    this.modeTarget.classList.remove("fa-grip", "fa-list");
    this.listTarget.classList.remove("channel-list-grid", "channel-list-list");
    if (this.isGrid) {
      this.modeTarget.classList.add("fa-grip");
      this.listTarget.classList.add("channel-list-grid");
    } else {
      this.modeTarget.classList.add("fa-list");
      this.listTarget.classList.add("channel-list-list");
    }
  }
}
