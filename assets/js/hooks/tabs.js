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

      getTabs().forEach((tab, i) => {
        const selected = i === idx;
        tab.setAttribute("aria-selected", selected ? "true" : "false");
        tab.setAttribute("tabindex", selected ? "0" : "-1");
      });

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

      if (idx >= 0) selectedIdx = idx;
    });

    tabs.addEventListener("keydown", (e) => {
      const currentIdx = getTabs().indexOf(e.target.closest('[role="tab"]'));

      if (currentIdx < 0) return;

      const total = getTabs().length;
      let nextIdx;

      if (e.key === "ArrowRight") {
        nextIdx = (currentIdx + 1) % total;
      } else if (e.key === "ArrowLeft") {
        nextIdx = (currentIdx - 1 + total) % total;
      } else if (e.key === "Home") {
        nextIdx = 0;
      } else if (e.key === "End") {
        nextIdx = total - 1;
      } else {
        return;
      }

      e.preventDefault();
      select(nextIdx);
      getTabs()[nextIdx].focus();
    });

    this.restoreSelection = () => {
      const total = getTabs().length;

      if (total > 0) select(Math.min(selectedIdx, total - 1));
    };
  },

  // Restore selected tab on patch.
  updated() {
    this.restoreSelection();
  },
};
