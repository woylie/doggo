const domWriter = {
  setAttribute: (el, attr, value) => el.setAttribute(attr, value),
  removeAttribute: (el, attr) => el.removeAttribute(attr),
};

export function initMenuButton(button, writer = domWriter) {
  const getMenu = () =>
    document.getElementById(button.getAttribute("aria-controls"));

  // Opening from the keyboard puts the focus on an item straight away, which
  // is the difference from opening with a pointer.
  const open = (position) => {
    const menu = getMenu();

    if (!menu) return;

    writer.removeAttribute(menu, "hidden");
    writer.setAttribute(button, "aria-expanded", "true");

    const items = menu.querySelectorAll(
      '[role="menuitem"], [role="menuitemcheckbox"], [role="menuitemradio"]',
    );
    const item = position === "last" ? items[items.length - 1] : items[0];

    if (item) item.focus();
  };

  button.addEventListener("keydown", (e) => {
    if (e.key !== "ArrowDown" && e.key !== "ArrowUp") return;

    e.preventDefault();
    open(e.key === "ArrowDown" ? "first" : "last");
  });
}

export default {
  // The click opens the menu with a JS command that a patch applies again, so
  // opening from the keyboard has to go through the same API.
  mounted() {
    const js = this.js();

    initMenuButton(this.el, {
      setAttribute: (el, attr, value) => js.setAttribute(el, attr, value),
      removeAttribute: (el, attr) => js.removeAttribute(el, attr),
    });
  },
};
