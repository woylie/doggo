import { clamp, setRovingTabindex, targetIndex } from "../navigation.js";

// Controls the toolbar manages
const CONTROLS = 'a[href], button, input, select, textarea, [role="button"]';

// Controls that use the arrow keys themselves
const KEEPS_ARROWS =
  'textarea, select, [role="slider"], [role="spinbutton"], [role="combobox"], [role="listbox"], [role="textbox"]';

const TEXT_INPUTS = [
  "text",
  "search",
  "url",
  "tel",
  "email",
  "password",
  "number",
  "date",
  "datetime-local",
  "month",
  "time",
  "week",
  "range",
];

function keepsArrows(el) {
  if (el.matches(KEEPS_ARROWS)) return true;

  return el.tagName === "INPUT" && TEXT_INPUTS.includes(el.type);
}

function isDisabled(el) {
  return el.disabled || el.getAttribute("aria-disabled") === "true";
}

export function initToolbar(toolbar) {
  // Read on demand: a patch can add and remove controls.
  const getControls = () =>
    Array.from(toolbar.querySelectorAll(CONTROLS)).filter(
      (control) => !isDisabled(control),
    );

  const isVertical = () =>
    toolbar.getAttribute("aria-orientation") === "vertical";

  let activeIdx = 0;

  const setActive = (idx) => {
    activeIdx = idx;

    setRovingTabindex(getControls(), idx);
  };

  toolbar.addEventListener("focusin", (e) => {
    const idx = getControls().indexOf(e.target.closest(CONTROLS));

    if (idx >= 0 && idx !== activeIdx) setActive(idx);
  });

  toolbar.addEventListener("keydown", (e) => {
    const control = e.target.closest(CONTROLS);

    if (!control || keepsArrows(control)) return;

    const controls = getControls();
    const currentIdx = controls.indexOf(control);

    if (currentIdx < 0) return;

    const nextIdx = targetIndex(e.key, currentIdx, controls.length, {
      orientation: isVertical() ? "vertical" : "horizontal",
    });

    if (nextIdx === null) return;

    e.preventDefault();
    controls[nextIdx].focus();
  });

  const restoreTabStop = () => {
    const total = getControls().length;

    if (total > 0) setActive(clamp(activeIdx, total));
  };

  restoreTabStop();

  return { update: restoreTabStop };
}

export default {
  mounted() {
    this.instance = initToolbar(this.el);
  },

  // A patch renders every control in the tab order again.
  updated() {
    this.instance.update();
  },
};
