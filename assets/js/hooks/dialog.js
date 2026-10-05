// Native `<dialog>` behaviour, with the parts browsers do not all have yet
// filled in. Each fill is behind a feature test, so it drops out on its own as
// support arrives, and the markup is already the markup we want.
const hasCommand = () => "command" in HTMLButtonElement.prototype;
const hasClosedBy = () => "closedBy" in HTMLDialogElement.prototype;

// The modals of every instance in opening order, so that one shown again goes
// back under the ones opened after it.
const opened = [];

// `execJS` is the one thing a framework has to supply: the dialog runs the
// caller's `on_cancel` when it closes, and only the framework knows how.
export function initDialog(dialog, { execJS = () => {} } = {}) {
  let invoke;
  let opener;

  const closedBy = () => dialog.getAttribute("closedby");

  // The element the browser returns focus to on close.
  const remember = () => {
    opener = document.activeElement;
  };

  const showModal = () => {
    remember();
    dialog.showModal();
  };

  // Opening paths other than Doggo's, in browsers that fire it for dialogs.
  dialog.addEventListener("beforetoggle", (e) => {
    if (e.newState === "open") remember();
  });

  // Dispatched by `Doggo.show_modal/2`.
  dialog.addEventListener("doggo:open", () => {
    if (!dialog.open) showModal();
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

      if (command === "show-modal" && !dialog.open) showModal();
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

  // A move takes focus out of the dialog before the observer runs.
  let focused;

  dialog.addEventListener("focusin", (e) => {
    focused = e.target;
  });

  const hide = () => {
    if (!dialog.isConnected) return () => {};

    const restore = focused;
    const returnTo = opener;
    // A dialog still in the top layer keeps its place there on `showModal()`.
    dialog.parentNode.insertBefore(dialog, dialog.nextSibling);
    // Not `close()`, which runs `on_cancel`.
    dialog.removeAttribute("open");

    return () => {
      // `showModal()` records the focused element as the one to return to.
      returnTo?.focus({ preventScroll: true });
      dialog.showModal();
      opener = returnTo;
      restore?.focus();
    };
  };

  // A move takes the dialog out of the top layer and leaves it open. A patch
  // can move it without changing it, and LiveView then calls no `updated`.
  const moves = new MutationObserver(() => {
    // Browsers that notify in creation order run this before `toggles`.
    if (toggles.takeRecords().length) return toggled();
    if (!dialog.isConnected || !dialog.open || dialog.matches(":modal")) return;

    const index = opened.indexOf(hide);
    if (index < 0) return;

    // All leave the top layer before the first is shown, so that no opener is
    // inert when it takes focus.
    for (const show of opened.slice(index).map((other) => other())) {
      try {
        show();
      } catch (error) {
        reportError(error);
      }
    }
  });

  const forget = () => {
    const index = opened.indexOf(hide);
    if (index >= 0) opened.splice(index, 1);
  };

  const toggled = () => {
    if (!dialog.open) opener = undefined;

    if (dialog.matches(":modal")) {
      if (!opened.includes(hide)) opened.push(hide);

      moves.observe(document.documentElement, {
        childList: true,
        subtree: true,
      });
    } else {
      forget();
      moves.disconnect();
    }
  };

  const toggles = new MutationObserver(toggled);
  toggles.observe(dialog, { attributes: true, attributeFilter: ["open"] });
  toggled();

  return {
    destroy() {
      forget();
      toggles.disconnect();
      moves.disconnect();
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

  destroyed() {
    this.instance.destroy();
  },
};
