console.log('Vite ⚡️ Rails - GBL Admin')

// Stimulus
import { Application } from '@hotwired/stimulus'
import ResultsController from "./controllers/results_controller"

window.Stimulus = Application.start()
Stimulus.register("results", ResultsController)