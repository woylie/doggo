import { searchIndex, setRovingTabindex, targetIndex } from "../navigation.js";

const ITEMS =
  '[role="menuitem"], [role="menuitemcheckbox"], [role="menuitemradio"]';

const ORIENTATIONS = { menubar: "horizontal", menu: "vertical" };

// How long the characters a user types stay one search. The ARIA Authoring
// Practices describe this for type-ahead, and 500ms is taken from their
// example.
const SEARCH_MS = 500;

export default {
  mounted() {
    const menu = this.el;
    const role = menu.getAttribute("role");

    // Read on demand, and only the items of this menu: `menu_group` and
    // `menu_item_radio_group` nest, and a submenu has its own hook.
    const getItems = () =>
      Array.from(menu.querySelectorAll(ITEMS)).filter(
        (item) => item.closest('[role="menu"], [role="menubar"]') === menu,
      );

    let activeIdx = 0;
    let search = "";
    let searchTimeout;

    const setActive = (idx) => {
      activeIdx = idx;
      setRovingTabindex(getItems(), idx);
    };

    const moveTo = (idx) => {
      setActive(idx);
      getItems()[idx].focus();
    };

    // Whatever the user focused becomes the tab stop.
    menu.addEventListener("focusin", (e) => {
      const idx = getItems().indexOf(e.target.closest(ITEMS));

      if (idx >= 0 && idx !== activeIdx) setActive(idx);
    });

    const typeAhead = (key) => {
      clearTimeout(searchTimeout);
      search += key;
      searchTimeout = setTimeout(() => (search = ""), SEARCH_MS);

      // The same character typed again walks through the items starting with
      // it, rather than searching for a repeated string. Any other second
      // character refines the search, so it starts at the current item instead
      // of after it.
      const repeated = [...search].every((char) => char === search[0]);
      const needle = repeated ? search[0] : search;
      const from = repeated ? activeIdx : activeIdx - 1;

      const labels = getItems().map((item) => item.textContent);
      const idx = searchIndex(labels, needle, from);

      if (idx !== null) moveTo(idx);
    };

    // Closing belongs to the button that opened the menu, which the menu finds
    // through the `aria-controls` pointing at it.
    const close = () => {
      const button = document.querySelector(`[aria-controls="${menu.id}"]`);

      if (!button) return;

      menu.setAttribute("hidden", "");
      button.setAttribute("aria-expanded", "false");
      button.focus();
    };

    menu.addEventListener("keydown", (e) => {
      const items = getItems();
      const currentIdx = items.indexOf(e.target.closest(ITEMS));

      if (currentIdx < 0) return;

      if (e.key === "Escape") {
        e.preventDefault();
        // One press closes one thing: a menu inside a dialog must not close
        // the dialog as well.
        e.stopPropagation();
        close();
        return;
      }

      const nextIdx = targetIndex(e.key, currentIdx, items.length, {
        orientation: ORIENTATIONS[role],
      });

      if (nextIdx !== null) {
        e.preventDefault();
        moveTo(nextIdx);
        return;
      }

      // A single printable character, and no modifier, is a search rather than
      // a shortcut.
      if (e.key.length === 1 && !e.metaKey && !e.ctrlKey && !e.altKey) {
        e.preventDefault();
        typeAhead(e.key);
      }
    });

    this.restoreTabStop = () => {
      const items = getItems();

      if (items.length > 0) {
        setActive(Math.min(activeIdx, items.length - 1));
      }
    };

    this.restoreTabStop();
  },

  updated() {
    this.restoreTabStop();
  },
};
