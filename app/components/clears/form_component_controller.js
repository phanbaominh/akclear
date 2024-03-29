import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["link", "videoFrame", "toggleVideoFrame"];

  connect() {
    this.embedLink();
  }

  hideVideoFrame(event, target = null) {
    target = target || this.videoFrameTarget;
    target.classList.add("hidden");
    target.parentElement.classList.add("hidden");
    target.parentElement.setAttribute("aria-hidden", true);
    target.src = "";
  }

  highlight({ detail: { operatorId } }) {
    this.element
      .querySelectorAll(".operators__highlightable")
      .forEach((card) => {
        card.classList.remove("outline", "outline-primary");
        if (card.dataset.operatorId == operatorId) {
          card.classList.add("outline", "outline-primary");
        }
      });
  }
  embedLink(event, target = null) {
    target = target || (this.hasVideoFrameTarget && this.videoFrameTarget);
    if (!target) return;

    if (!this.linkTarget.value.match(/http.*youtube.*watch\?v=/)) {
      this.hideVideoFrame();
      return;
    }

    target.classList.remove("hidden");
    target.parentElement.classList.remove("hidden");
    target.parentElement.removeAttribute("aria-hidden");
    target.src = this.linkTarget.value.replace(/watch\?v=/, "embed/");
  }

  toggleShowVideo(event) {
    if (event.target.checked) {
      this.embedLink(event, this.toggleVideoFrameTarget);
    } else {
      this.hideVideoFrame(event, this.toggleVideoFrameTarget);
    }
  }
}
