import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static outlets = ["clears--form"];
  connect() {
    this.element.textContent = "Hello World 1!";
  }

  test() {
    console.log({ test: this.hasClears__FormOutlet });
    this.clearsFormOutlet.test2();
  }

  test2() {
    console("oh yeah");
  }
}
