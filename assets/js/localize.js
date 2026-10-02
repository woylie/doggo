import { absolute } from "./time_format.js";
import { watch } from "./observer.js";

const written = new WeakMap();

function localizeTime(el) {
  try {
    const result = absolute(el, el.dataset.localize);
    if (!result) return;

    // Only write if the value differs to prevent observer from reacting to its
    // own changes.
    if (el.textContent.trim() !== result.text) el.textContent = result.text;
    written.set(el, result.text);

    if (result.title && el.title !== result.title) el.title = result.title;
  } catch {
    // Unknown zones or options are ignored and the server value is shown.
  }
}

const watcher = {
  selector: "[data-localize]:not([data-relative])",
  update: localizeTime,
  written,
};

export function localizeTimes(root = document) {
  watch(root, watcher);
}
