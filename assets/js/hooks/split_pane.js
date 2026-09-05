// The property the caller's stylesheet reads.
const POSITION = "--split-pane-position";

const STEP = 1;
const SHIFT_STEP = 10;

export default {
  mounted() {
    const pane = this.el;
    const separator = pane.querySelector(':scope > [role="separator"]');

    if (!separator) return;

    const numberOf = (name) => Number(separator.getAttribute(name));
    const min = () => numberOf("aria-valuemin");
    const max = () => numberOf("aria-valuemax");
    const isVertical = () =>
      separator.getAttribute("aria-orientation") === "vertical";

    let position = numberOf("aria-valuenow");

    // Where Enter goes back to. Any size above the minimum counts, so that a
    // pane collapsed with Home or with the pointer can be brought back too.

    // Where Enter goes back to: the last position that was not the minimum.
    let expandedSize = null;

    // Written through the CSSOM, which is not blocked under a strict content
    // security policy.
    const apply = (next) => {
      position = Math.min(Math.max(Math.round(next), min()), max());
      if (position > min()) expandedSize = position;

      pane.style.setProperty(POSITION, `${position}%`);
      separator.setAttribute("aria-valuenow", String(position));
    };

    // A vertical separator stands between two panes side by side, so it moves
    // along the x axis, and a horizontal one along the y axis.
    const fromPointer = (event) => {
      const box = pane.getBoundingClientRect();

      return isVertical()
        ? ((event.clientX - box.left) / box.width) * 100
        : ((event.clientY - box.top) / box.height) * 100;
    };

    separator.addEventListener("pointerdown", (e) => {
      // Capture keeps the drag alive while the pointer is outside the
      // separator, and it keeps the drag from selecting text. Preventing the
      // default would take the focus off the click, and the keys have to work
      // right after a drag.
      separator.setPointerCapture(e.pointerId);
    });

    separator.addEventListener("pointermove", (e) => {
      if (!separator.hasPointerCapture(e.pointerId)) return;

      apply(fromPointer(e));
    });

    separator.addEventListener("keydown", (e) => {
      const step = e.shiftKey ? SHIFT_STEP : STEP;
      const [less, more] = isVertical()
        ? ["ArrowLeft", "ArrowRight"]
        : ["ArrowUp", "ArrowDown"];

      if (e.key === more) {
        apply(position + step);
      } else if (e.key === less) {
        apply(position - step);
      } else if (e.key === "Home") {
        apply(min());
      } else if (e.key === "End") {
        apply(max());
      } else if (e.key === "Enter") {
        if (position > min()) {
          apply(min());
        } else if (expandedSize !== null) {
          apply(expandedSize);
        }
      } else {
        return;
      }

      e.preventDefault();
    });

    this.restore = () => apply(position);
    this.restore();
  },

  // A patch renders the position the server knows about.
  updated() {
    this.restore();
  },
};
