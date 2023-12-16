import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["listMode", "gridMode", "list"];
  static values = { isGrid: Boolean };

  connect() {
    this.isGrid = true;
  }

  toggle() {
    this.isGrid = !this.isGrid;
    this.listModeTarget.classList.add("hidden");
    this.gridModeTarget.classList.add("hidden");
    this.listTarget.classList.remove("channel-list-grid", "channel-list-list");
    if (this.isGrid) {
      this.gridModeTarget.classList.remove("hidden");
      this.listTarget.classList.add("channel-list-grid");
    } else {
      this.listModeTarget.classList.remove("hidden");
      this.listTarget.classList.add("channel-list-list");
    }
  }

  listTargetConnected() {
    if (this.isGrid !== undefined) {
      this.isGrid = !this.isGrid;
      this.toggle();
    }
  }
}
