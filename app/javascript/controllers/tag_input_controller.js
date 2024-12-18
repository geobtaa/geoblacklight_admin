// app/javascript/controllers/tag_input_controller.js

import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select";

export default class extends Controller {
  // Triggered when the Stimulus controller is connected to the DOM.
  connect() {
    console.log("Stimulus - Tag Input controller connected");
    this.initializeTomSelect();
  }

  // Triggered when the Stimulus controller is removed from the DOM.
  disconnect() {
    this.destroyTomSelect();
  }

  // Initialize the TomSelect dropdown with the desired configurations.
  initializeTomSelect() {
    // Return early if no element is associated with the controller.
    if (!this.element) return;

    // Create a new TomSelect instance with the specified configuration.
    // see: https://tom-select.js.org/docs/
    // value, label, search, placeholder, etc can all be passed as static values instead of hard-coded.
    this.select = new TomSelect(this.element, {
      placeholder: "Add tags",
      persist: false,
      create: true,
      createOnBlur: true
    });
  }

  // Cleanup: Destroy the TomSelect instance when the controller is disconnected.
  destroyTomSelect() {
    if (this.select) {
      this.select.destroy();
    }
  }
}