import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["likeCounter"];
  static values = { liked: Boolean };

  connect() {
    this.liked = this.likedValue;
  }

  changeLikeCount() {
    if (this.liked) {
      this.likeCounterTarget.textContent--;
      this.liked = false;
      return;
    }
    this.liked = true;
    this.likeCounterTarget.textContent++;
  }
}
