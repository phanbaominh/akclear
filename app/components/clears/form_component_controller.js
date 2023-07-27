import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["link", "videoFrame"];

  hideVideoFrame() {
    this.videoFrameTarget.classList.add("hidden");
    this.videoFrameTarget.src = "";
  }

  highlight({ detail: { operatorId } }) {
    this.element.querySelectorAll(".operators__card").forEach((card) => {
      card.classList.remove("outline", "outline-primary");
      if (card.dataset.operatorId == operatorId) {
        card.classList.add("outline", "outline-primary");
      }
    });
  }
  embedLink() {
    if (!this.linkTarget.value.match(/http.*youtube.*watch\?v=/)) {
      this.hideVideoFrame();
      return;
    }

    this.videoFrameTarget.classList.remove("hidden");
    this.videoFrameTarget.src = this.linkTarget.value.replace(
      /watch\?v=/,
      "embed/"
    );
  }
}
