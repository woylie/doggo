// Keeps an index within a list of `total` elements.
export function clamp(idx, total) {
  return Math.min(Math.max(idx, 0), total - 1);
}

// Adds `offset` to `idx` while staying within the total range. Wraps around at
// the ends if `wrap` is true.
export function stepIndex(idx, offset, total, { wrap = true } = {}) {
  if (wrap) return (idx + offset + total) % total;

  return clamp(idx + offset, total);
}

// Returns the index the key moves to, or `null` if the key is not an arrow,
// Home or End. The caller passes the current index, because each hook gets it
// from somewhere else: the carousel from the slide in view, tabs and toolbars
// from the focused element.
export function targetIndex(
  key,
  currentIdx,
  total,
  { orientation = "horizontal", wrap = true } = {},
) {
  const [previous, next] =
    orientation === "vertical"
      ? ["ArrowUp", "ArrowDown"]
      : ["ArrowLeft", "ArrowRight"];

  if (key === next) return stepIndex(currentIdx, 1, total, { wrap });
  if (key === previous) return stepIndex(currentIdx, -1, total, { wrap });
  if (key === "Home") return 0;
  if (key === "End") return total - 1;

  return null;
}

// Sets `tabindex` to 0 on the element at `activeIdx` and to -1 on the rest, so
// that the list is one tab stop.
export function setRovingTabindex(elements, activeIdx) {
  elements.forEach((el, idx) => {
    el.setAttribute("tabindex", idx === activeIdx ? "0" : "-1");
  });
}

// Sets `aria-selected` to true on the tab at `activeIdx` and to false on the
// rest, and sets `tabindex` the same way as above. Used by `tabs` and by the
// carousel pagination, which is also a tab list.
export function selectTab(tabs, activeIdx) {
  tabs.forEach((tab, idx) => {
    tab.setAttribute("aria-selected", idx === activeIdx ? "true" : "false");
  });

  setRovingTabindex(tabs, activeIdx);
}

// Returns the index of the next label starting with `search`, after `fromIdx`,
// wrapping around, or `null` if none matches. Used for type-ahead in menus.
export function searchIndex(labels, search, fromIdx) {
  const needle = search.toLowerCase();
  const total = labels.length;

  for (let offset = 1; offset <= total; offset++) {
    const idx = (fromIdx + offset) % total;

    if (labels[idx].trim().toLowerCase().startsWith(needle)) return idx;
  }

  return null;
}
