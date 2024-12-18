console.log('Vite ⚡️ Rails - GBL Admin')

// Import Stimulus and controllers
import { Application } from '@hotwired/stimulus'
import ResultsController from "./controllers/results_controller"
import TagInputController from "./controllers/tag_input_controller"

// Initialize Stimulus
window.Stimulus = Application.start()

// Register controllers
Stimulus.register("results", ResultsController)
Stimulus.register("taginput", TagInputController)

// Import channels
import './channels';