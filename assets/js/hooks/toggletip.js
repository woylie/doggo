// A long announcement cannot be interrupted, so the text is cut. The region is
// emptied afterwards, since the open panel holds the same text.
const maxLength = 250;
const clearAfter = 1000;

const announcement = (panel) => {
  const text = panel.textContent.replace(/\s+/g, " ").trim();
  return text.length > maxLength ? `${text.slice(0, maxLength)}…` : text;
};

// Remove the positioning once CSS anchor positioning is widely baseline
// available; the example CSS places the panel where it is supported.
const anchored = () => window.CSS?.supports?.("position-area: block-end");

export function initToggletip(toggletip) {
  const button = toggletip.querySelector(":scope > button");
  const panel = toggletip.querySelector(":scope > [popover]");
  const status = toggletip.querySelector(':scope > [role="status"]');
  let timer;

  const place = () => {
    const rect = button.getBoundingClientRect();
    const rtl = getComputedStyle(toggletip).direction === "rtl";
    const start = rtl ? window.innerWidth - rect.right : rect.left;

    const style = {
      inset: "auto",
      margin: "0",
      "margin-block-start": "var(--toggletip-offset)",
      "inset-block-start": `${rect.bottom}px`,
      "inset-inline-start": `${start}px`,
    };

    for (const [name, value] of Object.entries(style)) {
      panel.style.setProperty(name, value);
    }
  };

  const position = () => {
    if (!anchored() && panel.matches(":popover-open")) place();
  };

  const beforeToggle = (e) => {
    if (!anchored() && e.newState === "open") place();
  };

  const announce = (e) => {
    clearTimeout(timer);
    status.textContent = e.newState === "open" ? announcement(panel) : "";
    timer = setTimeout(() => (status.textContent = ""), clearAfter);
  };

  panel.addEventListener("beforetoggle", beforeToggle);
  panel.addEventListener("toggle", announce);
  window.addEventListener("scroll", position, true);
  window.addEventListener("resize", position);

  return {
    update: position,
    destroy() {
      clearTimeout(timer);
      panel.removeEventListener("beforetoggle", beforeToggle);
      panel.removeEventListener("toggle", announce);
      window.removeEventListener("scroll", position, true);
      window.removeEventListener("resize", position);
    },
  };
}

export default {
  mounted() {
    this.instance = initToggletip(this.el);
  },

  updated() {
    this.instance.update();
  },

  destroyed() {
    this.instance.destroy();
  },
};
