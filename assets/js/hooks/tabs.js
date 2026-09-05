import { clamp, selectTab, targetIndex } from "../navigation.js";

export default {
  mounted() {
    const tabs = this.el;

    const getTabs = () =>
      Array.from(
        tabs.querySelectorAll(':scope > [role="tablist"] > [role="tab"]'),
      );

    const getPanels = () =>
      Array.from(tabs.querySelectorAll(':scope > [role="tabpanel"]'));

    let selectedIdx = 0;

    const select = (idx) => {
      selectedIdx = idx;

      selectTab(getTabs(), idx);

      getPanels().forEach((panel, i) => {
        if (i === idx) {
          panel.removeAttribute("hidden");
        } else {
          panel.setAttribute("hidden", "");
        }
      });
    };

    tabs.addEventListener("click", (e) => {
      const idx = getTabs().indexOf(e.target.closest('[role="tab"]'));

      if (idx >= 0) select(idx);
    });

    // Dispatched by `Doggo.show_tab/3`. One-based index.
    tabs.addEventListener("doggo:show-tab", (e) => {
      const idx = e.detail.index - 1;

      if (idx >= 0 && idx < getTabs().length) select(idx);
    });

    tabs.addEventListener("keydown", (e) => {
      const currentIdx = getTabs().indexOf(e.target.closest('[role="tab"]'));

      if (currentIdx < 0) return;

      const vertical =
        tabs
          .querySelector('[role="tablist"]')
          .getAttribute("aria-orientation") === "vertical";

      const nextIdx = targetIndex(e.key, currentIdx, getTabs().length, {
        orientation: vertical ? "vertical" : "horizontal",
      });

      if (nextIdx === null) return;

      e.preventDefault();
      select(nextIdx);
      getTabs()[nextIdx].focus();
    });

    this.restoreSelection = () => {
      const total = getTabs().length;

      if (total > 0) select(clamp(selectedIdx, total));
    };
  },

  // Restore selected tab on patch.
  updated() {
    this.restoreSelection();
  },
};
