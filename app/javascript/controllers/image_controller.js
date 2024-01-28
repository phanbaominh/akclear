import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  enlarge() {
    this.imageFrame.classList.remove("hidden");
    this.imageFrame.setAttribute("src", this.currentImageSrc);
    this.element.classList.add("outline", "outline-primary");
  }

  minimize() {
    this.imageFrame.classList.add("hidden");
    this.imageFrame.setAttribute("src", "");
    this.element.classList.remove("outline", "outline-primary");
  }

  get imageFrame() {
    return document.querySelector("#image_frame");
  }

  get currentImageSrc() {
    return this.element.getAttribute("src");
  }
}
