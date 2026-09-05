export function initTooltip(tooltip) {
  const isActive = () =>
    tooltip.matches(":hover") || tooltip.matches(":focus-within");

  const isShown = () => isActive() && !tooltip.hasAttribute("data-dismissed");

  // A dismissed tooltip stays dismissed until the pointer and the focus have
  // both left.
  const clearWhenLeft = () =>
    setTimeout(() => {
      if (!isActive()) tooltip.removeAttribute("data-dismissed");
    }, 0);

  const dismiss = (e) => {
    if (e.key !== "Escape" || !isShown()) return;

    tooltip.setAttribute("data-dismissed", "");

    // Stop propagation; a tooltip inside a dialog must not close the dialog
    // as well.
    e.stopPropagation();
  };

  // The listener sits on the window rather than on the tooltip, because a
  // tooltip shown by hovering has the focus somewhere else entirely, and a
  // key press goes to the focused element. WCAG 2.2 1.4.13 asks for that case
  // to be dismissible too.
  window.addEventListener("keydown", dismiss, true);

  tooltip.addEventListener("focusout", clearWhenLeft);
  tooltip.addEventListener("pointerleave", clearWhenLeft);

  return {
    destroy() {
      window.removeEventListener("keydown", dismiss, true);
    },
  };
}

export default {
  mounted() {
    this.instance = initTooltip(this.el);
  },

  destroyed() {
    this.instance.destroy();
  },
};
