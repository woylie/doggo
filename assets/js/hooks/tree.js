import { clamp, searchIndex, targetIndex } from "../navigation.js";

const SEARCH_MS = 500;

const isBranch = (item) => item.hasAttribute("aria-expanded");
const isExpanded = (item) => item.getAttribute("aria-expanded") === "true";
const groupOf = (item) => item.querySelector(':scope > [role="group"]');
const labelOf = (item) =>
  item.querySelector(':scope > :not(button):not([role="group"])');
const parentOf = (item) =>
  item.parentElement.closest('[role="treeitem"]') || null;

const labelText = (item) => {
  const label = labelOf(item);

  if (!label) return "";

  const copy = label.cloneNode(true);

  for (const node of copy.querySelectorAll('[aria-hidden="true"], svg')) {
    node.remove();
  }

  return copy.textContent;
};

const domWriter = {
  setAttribute: (el, attr, value) => el.setAttribute(attr, value),
  removeAttribute: (el, attr) => el.removeAttribute(attr),
};

export function initTree(tree, writer = domWriter) {
  // Visible items only. A collapsed branch takes its descendants out of the
  // sequence.
  const getItems = () =>
    Array.from(tree.querySelectorAll('[role="treeitem"]')).filter(
      (item) => !item.closest('[role="group"][hidden]'),
    );

  let activeIdx = 0;
  let search = "";
  let searchTimeout;

  // Every item, not just the visible ones: a hidden item would keep the tab
  // index it had before the collapse.
  const setActive = (idx) => {
    activeIdx = idx;

    const active = getItems()[idx];

    for (const item of tree.querySelectorAll('[role="treeitem"]')) {
      item.setAttribute("tabindex", item === active ? "0" : "-1");
    }
  };

  const moveTo = (idx) => {
    setActive(idx);
    getItems()[idx].focus();
  };

  const setExpanded = (item, expanded) => {
    writer.setAttribute(item, "aria-expanded", expanded ? "true" : "false");

    const group = groupOf(item);

    if (group) {
      if (expanded) {
        writer.removeAttribute(group, "hidden");
      } else {
        writer.setAttribute(group, "hidden", "");
      }
    }
  };

  // Only the caret toggles. A click on the label is the caller's, for
  // selection. The caret is `aria-hidden`: the arrow keys already do this.
  tree.addEventListener("click", (e) => {
    const item = e.target.closest('[role="treeitem"]');

    if (!item || !isBranch(item)) return;

    // The item's own caret, not one a caller put in the label.
    const caret = item.querySelector(":scope > button");

    if (!caret || !caret.contains(e.target)) return;

    setExpanded(item, !isExpanded(item));
    item.focus();
  });

  tree.addEventListener("focusin", (e) => {
    const idx = getItems().indexOf(e.target.closest('[role="treeitem"]'));

    if (idx >= 0 && idx !== activeIdx) setActive(idx);
  });

  const typeAhead = (key) => {
    clearTimeout(searchTimeout);
    search += key;
    searchTimeout = setTimeout(() => (search = ""), SEARCH_MS);

    const repeated = [...search].every((char) => char === search[0]);
    const items = getItems();
    const labels = items.map(labelText);
    const idx = searchIndex(
      labels,
      repeated ? search[0] : search,
      repeated ? activeIdx : activeIdx - 1,
    );

    if (idx !== null) moveTo(idx);
  };

  tree.addEventListener("keydown", (e) => {
    const items = getItems();
    const item = e.target.closest('[role="treeitem"]');
    const currentIdx = items.indexOf(item);

    if (currentIdx < 0) return;

    // Right opens a branch, then walks into it. Left closes it, then walks out.
    if (e.key === "ArrowRight") {
      e.preventDefault();

      if (isBranch(item) && !isExpanded(item)) {
        setExpanded(item, true);
      } else if (isBranch(item)) {
        const child = groupOf(item)?.querySelector('[role="treeitem"]');

        if (child) moveTo(getItems().indexOf(child));
      }

      return;
    }

    if (e.key === "ArrowLeft") {
      e.preventDefault();

      if (isBranch(item) && isExpanded(item)) {
        setExpanded(item, false);
      } else {
        const parent = parentOf(item);

        if (parent) moveTo(getItems().indexOf(parent));
      }

      return;
    }

    const nextIdx = targetIndex(e.key, currentIdx, items.length, {
      orientation: "vertical",
      wrap: false,
    });

    if (nextIdx !== null) {
      e.preventDefault();
      moveTo(nextIdx);
      return;
    }

    if (e.key.length === 1 && !e.metaKey && !e.ctrlKey && !e.altKey) {
      e.preventDefault();
      typeAhead(e.key);
    }
  });

  const restore = () => {
    const items = getItems();

    if (items.length > 0) setActive(clamp(activeIdx, items.length));
  };

  restore();

  return { update: restore };
}

export default {
  mounted() {
    const js = this.js();

    this.instance = initTree(this.el, {
      setAttribute: (el, attr, value) => js.setAttribute(el, attr, value),
      removeAttribute: (el, attr) => js.removeAttribute(el, attr),
    });
  },

  updated() {
    this.instance.update();
  },
};
