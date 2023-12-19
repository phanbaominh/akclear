import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static values = {
    endTime: String,
  };

  connect() {
    this.endTime = new Date(this.endTimeValue).getTime();
    this.updateTimer();

    this.startTimer();
  }

  startTimer() {
    this.timerInterval = setInterval(this.updateTimer.bind(this), 1000);
  }

  updateTimer() {
    // Get todays date and time
    var now = new Date().getTime();

    // Find the distance between now an the count down date
    var distance = this.endTime - now;

    // Time calculations for days, hours, minutes and seconds
    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hours = Math.floor(
      (distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
    );
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

    // Output the result in an element with id="demo"
    this.element.textContent =
      days + "d " + hours + "h " + minutes + "m " + seconds + "s ";

    // If the count down is over, write some text
    if (distance < 0) {
      clearInterval(x);
      this.element.textContent = "ENDED";
    }
  }

  disconnect() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }
  }
}
