import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static outlets = ["image"];

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

  goNext() {
    this.imageOutlets.forEach((image, index) => {
      // enlarge next image
      if (image === this) {
        const nextImage =
          this.imageOutlets[(index + 1) % this.imageOutlets.length];
        if (nextImage) {
          this.minimize();
          nextImage.element.focus();
          nextImage.enlarge();
          return;
        }
      }
    });
  }

  goPrev() {
    this.imageOutlets.forEach((image, index) => {
      // enlarge next image
      if (image === this) {
        if (index == 0) return;
        const nextImage = this.imageOutlets[index - 1];
        if (nextImage) {
          this.minimize();
          nextImage.element.focus();
          nextImage.enlarge();
          return;
        }
      }
    });
  }

  get imageFrame() {
    return document.querySelector("#image_frame");
  }

  get currentImageSrc() {
    return this.element.getAttribute("src");
  }
}
