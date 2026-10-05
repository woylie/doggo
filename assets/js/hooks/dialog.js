// Native `<dialog>` behaviour, with the parts browsers do not all have yet
// filled in. Each fill is behind a feature test, so it drops out on its own as
// support arrives, and the markup is already the markup we want.
const hasCommand = () => "command" in HTMLButtonElement.prototype;
const hasClosedBy = () => "closedBy" in HTMLDialogElement.prototype;

// `execJS` is the one thing a framework has to supply: the dialog runs the
// caller's `on_cancel` when it closes, and only the framework knows how.
export function initDialog(dialog, { execJS = () => {} } = {}) {
  let invoke;

  const closedBy = () => dialog.getAttribute("closedby");

  // Dispatched by `Doggo.show_modal/2`.
  dialog.addEventListener("doggo:open", () => {
    if (!dialog.open) dialog.showModal();
  });

  // Dispatched by `Doggo.hide_modal/2`.
  dialog.addEventListener("doggo:close", () => dialog.close());

  // The browser closes the dialog itself, so `on_cancel` runs from here
  // rather than from the control that closed it.
  dialog.addEventListener("close", () => {
    const command = dialog.getAttribute("data-cancel");

    if (command) execJS(dialog, command);
  });

  if (!hasCommand()) {
    // On the document, not on the dialog.
    invoke = (e) => {
      const button = e.target.closest("button[commandfor]");

      if (!button || button.getAttribute("commandfor") !== dialog.id) return;

      const command = button.getAttribute("command");

      if (command === "show-modal" && !dialog.open) dialog.showModal();
      else if (command === "close") dialog.close();
    };

    document.addEventListener("click", invoke);
  }

  if (!hasClosedBy()) {
    // `closedby="none"` has to hold Escape as well, which is the one part of
    // the attribute that native `<dialog>` does not give us anyway.
    dialog.addEventListener("cancel", (e) => {
      if (closedBy() === "none") e.preventDefault();
    });

    // A click on the backdrop reaches the dialog itself, never a child, so
    // the target is the test for being outside.
    dialog.addEventListener("click", (e) => {
      if (closedBy() === "any" && e.target === dialog) dialog.close();
    });
  }

  // A patch that moves the dialog takes it out of the top layer and leaves it
  // open but not modal. Removing `open` instead of calling `close()` keeps
  // `on_cancel` from running.
  const update = () => {
    if (!dialog.open || dialog.matches(":modal")) return;

    const focused = document.activeElement;

    dialog.removeAttribute("open");
    dialog.showModal();

    if (dialog.contains(focused)) focused.focus();
  };

  return {
    update,

    destroy() {
      if (invoke) document.removeEventListener("click", invoke);
    },
  };
}

export default {
  mounted() {
    this.instance = initDialog(this.el, {
      execJS: (el, command) => this.liveSocket.execJS(el, command),
    });
  },

  updated() {
    this.instance.update();
  },

  destroyed() {
    this.instance.destroy();
  },
};
