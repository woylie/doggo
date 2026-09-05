import { clamp, searchIndex, targetIndex } from "../navigation.js";

const SEARCH_MS = 500;

const isBranch = (item) => item.hasAttribute("aria-expanded");
const isExpanded = (item) => item.getAttribute("aria-expanded") === "true";
const groupOf = (item) => item.querySelector(':scope > [role="group"]');
const parentOf = (item) =>
  item.parentElement.closest('[role="treeitem"]') || null;

export default {
  mounted() {
    const tree = this.el;

    // Visible items only. A collapsed branch takes its descendants out of the
    // sequence.
    const getItems = () =>
      Array.from(tree.querySelectorAll('[role="treeitem"]')).filter(
        (item) => !item.closest('[role="group"][hidden]'),
      );

    // The hook owns the expanded state. A patch re-renders the server's
    // version, so it is remembered by position and applied again.
    const pathOf = (item) => {
      const path = [];

      for (let node = item; node; node = parentOf(node)) {
        const siblings = Array.from(
          node.parentElement.querySelectorAll(':scope > [role="treeitem"]'),
        );
        path.unshift(siblings.indexOf(node));
      }

      return path.join("-");
    };

    const expandedPaths = new Set();
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
      item.setAttribute("aria-expanded", expanded ? "true" : "false");

      const group = groupOf(item);

      if (group) {
        if (expanded) {
          group.removeAttribute("hidden");
        } else {
          group.setAttribute("hidden", "");
        }
      }

      const path = pathOf(item);

      if (expanded) {
        expandedPaths.add(path);
      } else {
        expandedPaths.delete(path);
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
      // The item's own label, not the nested items and not the caret.
      const labels = items.map(
        (item) => item.querySelector(":scope > span").textContent,
      );
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
          const child = groupOf(item).querySelector('[role="treeitem"]');

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

    this.restore = () => {
      for (const item of tree.querySelectorAll('[role="treeitem"]')) {
        if (isBranch(item) && expandedPaths.has(pathOf(item))) {
          setExpanded(item, true);
        }
      }

      const items = getItems();

      if (items.length > 0) setActive(clamp(activeIdx, items.length));
    };

    this.restore();
  },

  updated() {
    this.restore();
  },
};
