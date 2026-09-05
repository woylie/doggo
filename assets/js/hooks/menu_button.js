export function initMenuButton(button) {
  const getMenu = () =>
    document.getElementById(button.getAttribute("aria-controls"));

  // Opening from the keyboard puts the focus on an item straight away, which
  // is the difference from opening with a pointer.
  const open = (position) => {
    const menu = getMenu();

    if (!menu) return;

    menu.removeAttribute("hidden");
    button.setAttribute("aria-expanded", "true");

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
  mounted() {
    initMenuButton(this.el);
  },
};
