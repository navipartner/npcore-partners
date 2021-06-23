import { bootstrapBeforeLoad } from "./bootstrap/bootstrap.before.js";
import { initializeDragonglass } from "./dragonglass-initialize.js";

bootstrapBeforeLoad().then(() => {
    initializeDragonglass();
});
