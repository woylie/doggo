import {
  clamp,
  selectTab,
  setRovingTabindex,
  targetIndex,
} from "../navigation.js";

const isDisabled = (tab) => tab.getAttribute("aria-disabled") === "true";

export function initTabs(tabs) {
  const getTabs = () =>
    Array.from(
      tabs.querySelectorAll(':scope > [role="tablist"] > [role="tab"]'),
    );

  const getPanels = () =>
    Array.from(tabs.querySelectorAll(':scope > [role="tabpanel"]'));

  let selectedIdx = Math.max(
    getTabs().findIndex((tab) => tab.getAttribute("aria-selected") === "true"),
    0,
  );

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
    const tab = e.target.closest('[role="tab"]');
    const idx = getTabs().indexOf(tab);

    if (idx >= 0 && !isDisabled(tab)) select(idx);
  });

  // Dispatched by `Doggo.show_tab/3`. One-based index.
  tabs.addEventListener("doggo:show-tab", (e) => {
    const idx = e.detail.index - 1;
    const tab = getTabs()[idx];

    if (tab && !isDisabled(tab)) select(idx);
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

    const allTabs = getTabs();

    if (isDisabled(allTabs[nextIdx])) {
      setRovingTabindex(allTabs, nextIdx);
    } else {
      select(nextIdx);
    }

    allTabs[nextIdx].focus();
  });

  const restoreSelection = () => {
    const allTabs = getTabs();

    if (allTabs.length === 0) return;

    const idx = clamp(selectedIdx, allTabs.length);
    const enabledIdx = allTabs.findIndex((tab) => !isDisabled(tab));

    select(isDisabled(allTabs[idx]) && enabledIdx >= 0 ? enabledIdx : idx);
  };

  return { update: restoreSelection };
}

export default {
  mounted() {
    this.instance = initTabs(this.el);
  },

  // Restore selected tab on patch.
  updated() {
    this.instance.update();
  },
};
