import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { initDialog } from "../js/hooks/dialog.js";
import fixture from "../../test/fixtures/modal.html?raw";
import { render } from "./dom.js";

const dispatch = (el, name) =>
  el.dispatchEvent(new window.CustomEvent(name, { bubbles: true }));

// happy-dom has neither, so the hook's fallbacks are run.
const withSupport = (prototype, property, body) => {
  Object.defineProperty(prototype, property, {
    value: null,
    configurable: true,
  });

  try {
    body();
  } finally {
    delete prototype[property];
  }
};

describe("initDialog", () => {
  let el;
  let hook;
  let execJS;

  beforeEach(() => {
    el = render(fixture);
    execJS = vi.fn();
    hook = initDialog(el, { execJS });
  });

  afterEach(() => hook.destroy());

  it("opens as a modal when Doggo.show_modal dispatches", () => {
    dispatch(el, "doggo:open");

    expect(el.open).toBe(true);
  });

  // A real browser throws InvalidStateError on showModal() for a dialog that is
  // already open, happy-dom does not, so the call is asserted.
  it("leaves an open dialog alone", () => {
    const showModal = vi.spyOn(el, "showModal");

    dispatch(el, "doggo:open");
    dispatch(el, "doggo:open");

    expect(showModal).toHaveBeenCalledOnce();
    expect(el.open).toBe(true);
  });

  it("closes when Doggo.hide_modal dispatches", () => {
    dispatch(el, "doggo:open");
    dispatch(el, "doggo:close");

    expect(el.open).toBe(false);
  });

  it("runs on_cancel when the dialog closes", () => {
    dispatch(el, "doggo:open");
    el.close();

    expect(execJS).toHaveBeenCalledWith(el, el.getAttribute("data-cancel"));
  });

  it("does not run on_cancel when there is none", () => {
    el.removeAttribute("data-cancel");
    dispatch(el, "doggo:open");
    el.close();

    expect(execJS).not.toHaveBeenCalled();
  });

  // happy-dom has no top layer, so these tests keep a fake one that behaves
  // like Chrome's.
  describe("after a move", () => {
    let topLayer;
    let removals;
    let beforetoggle;

    // MutationObserver callbacks run after the code that moved the node.
    const settle = () => new Promise((resolve) => setTimeout(resolve));

    const drop = (records) => {
      for (const record of records) {
        for (const node of record.removedNodes) {
          topLayer = topLayer.filter((dialog) => !node.contains(dialog));
        }
      }
    };

    // Also read on demand, so that the order of the observers does not matter.
    const sync = () => drop(removals.takeRecords());

    // The way morphdom moves a node: something new goes in, and the node is
    // appended after it.
    const move = (node) => {
      node.parentNode.append(document.createElement("p"));
      node.parentNode.append(node);
    };

    const open = async () => {
      dispatch(el, "doggo:open");
      await settle();
      el.showModal.mockClear();
    };

    const fakeTopLayer = (dialog) => {
      const matches = dialog.matches.bind(dialog);
      const showModal = dialog.showModal.bind(dialog);
      const close = dialog.close.bind(dialog);

      vi.spyOn(dialog, "matches").mockImplementation((selector) => {
        if (selector !== ":modal") return matches(selector);

        sync();
        return dialog.open && topLayer.includes(dialog);
      });

      vi.spyOn(dialog, "showModal").mockImplementation(() => {
        if (dialog.open) {
          throw new window.DOMException("open", "InvalidStateError");
        }

        sync();
        if (beforetoggle) toggle(dialog, "open");
        showModal();
        if (!topLayer.includes(dialog)) topLayer.push(dialog);
        (dialog.querySelector(focusable) ?? dialog).focus();
      });

      vi.spyOn(dialog, "close").mockImplementation(() => {
        close();
        topLayer = topLayer.filter((other) => other !== dialog);
      });
    };

    beforeEach(() => {
      topLayer = [];
      beforetoggle = false;
      removals = new MutationObserver(drop);
      removals.observe(document.documentElement, {
        childList: true,
        subtree: true,
      });
      fakeTopLayer(el);
    });

    afterEach(() => removals.disconnect());

    // The first focusable descendant, as Chromium chooses it.
    const focusable =
      "[autofocus], button:not([disabled]), a[href], input, select, textarea, [tabindex]";

    const toggle = (dialog, newState) => {
      const event = new window.Event("beforetoggle");
      event.newState = newState;
      dialog.dispatchEvent(event);
    };

    const opener = () => {
      const button = document.createElement("button");
      document.body.append(button);
      button.focus();
      return button;
    };

    // The element `showModal()` records as the one to return focus to.
    const recordReturn = () => {
      const recorded = {};
      const fake = el.showModal.getMockImplementation();
      el.showModal.mockImplementation(() => {
        recorded.returnTo = document.activeElement;
        fake();
      });
      return recorded;
    };

    it("shows a moved dialog as a modal again", async () => {
      await open();

      move(el);
      await settle();

      expect(el.showModal).toHaveBeenCalledOnce();
      expect(el.matches(":modal")).toBe(true);
    });

    it("does not run on_cancel when it shows the dialog again", async () => {
      await open();

      move(el);
      await settle();

      expect(execJS).not.toHaveBeenCalled();
    });

    it("keeps focus inside the dialog", async () => {
      el.innerHTML = "<button>First</button><button>Second</button>";
      await open();
      const button = el.querySelectorAll("button")[1];
      button.focus();

      move(el);
      await settle();

      expect(document.activeElement).toBe(button);
    });

    it("keeps focus off the autofocus element", async () => {
      el.innerHTML = "<button autofocus>First</button><button>Second</button>";
      await open();
      const second = el.querySelectorAll("button")[1];
      second.focus();

      move(el);
      await settle();

      expect(document.activeElement).toBe(second);
    });

    it("focuses the opener before it shows the dialog again", async () => {
      const button = opener();
      el.innerHTML = "<button>Inside</button>";
      await open();
      el.querySelector("button").focus();
      const recorded = recordReturn();

      move(el);
      await settle();

      expect(recorded.returnTo).toBe(button);
    });

    it("does not scroll to the opener", async () => {
      const button = opener();
      await open();
      const focus = vi.spyOn(button, "focus");

      move(el);
      await settle();

      expect(focus).toHaveBeenCalledWith({ preventScroll: true });
    });

    it("records the opener when the command fill opens it", async () => {
      const button = opener();
      button.setAttribute("command", "show-modal");
      button.setAttribute("commandfor", el.id);
      el.innerHTML = "<button>Inside</button>";
      button.click();
      el.querySelector("button").focus();
      await settle();
      const recorded = recordReturn();

      move(el);
      await settle();

      expect(recorded.returnTo).toBe(button);
    });

    it("takes the opener from beforetoggle when the browser opens it", async () => {
      beforetoggle = true;
      const button = opener();
      el.innerHTML = "<button>Inside</button>";
      el.showModal();
      el.querySelector("button").focus();
      await settle();
      const recorded = recordReturn();

      move(el);
      await settle();

      expect(recorded.returnTo).toBe(button);
    });

    it("keeps the opener when focus comes back from outside", async () => {
      const button = opener();
      el.innerHTML = "<button>Inside</button>";
      await open();
      opener();
      el.querySelector("button").focus();
      const recorded = recordReturn();

      move(el);
      await settle();

      expect(recorded.returnTo).toBe(button);
    });

    it("keeps the opener when it cannot take focus during the re-show", async () => {
      beforetoggle = true;
      const button = opener();
      el.innerHTML = "<button>Inside</button>";
      await open();
      el.querySelector("button").focus();
      const focus = vi.spyOn(button, "focus").mockImplementation(() => {});
      move(el);
      await settle();
      focus.mockRestore();
      const recorded = recordReturn();

      move(el);
      await settle();

      expect(recorded.returnTo).toBe(button);
    });

    it("forgets the opener once the dialog closes", async () => {
      const button = opener();
      await open();
      el.close();
      await settle();
      button.blur();
      el.showModal();
      await settle();
      const recorded = recordReturn();

      move(el);
      await settle();

      expect(recorded.returnTo).not.toBe(button);
    });

    it("shows the dialog again when an element around it moves", async () => {
      const outer = document.createElement("div");
      const inner = document.createElement("div");
      document.body.append(outer);
      outer.append(inner);
      inner.append(el);
      await open();

      move(outer);
      await settle();

      expect(el.showModal).toHaveBeenCalledOnce();
    });

    it("ignores changes elsewhere on the page", async () => {
      await open();

      document.body.append(document.createElement("p"));
      await settle();

      expect(el.showModal).not.toHaveBeenCalled();
    });

    it("leaves a dialog opened without showModal alone", async () => {
      el.setAttribute("open", "");
      await settle();

      move(el);
      await settle();

      expect(el.showModal).not.toHaveBeenCalled();
    });

    it("leaves a closed dialog closed", async () => {
      move(el);
      await settle();

      expect(el.open).toBe(false);
    });

    it("leaves a dialog closed if it closes in the same task as the move", async () => {
      await open();

      move(el);
      el.close();
      await settle();

      expect(el.showModal).not.toHaveBeenCalled();
      expect(el.open).toBe(false);
    });

    it("stops watching once the dialog closes", async () => {
      await open();
      el.close();
      await settle();
      el.setAttribute("open", "");

      move(el);
      await settle();

      expect(el.showModal).not.toHaveBeenCalled();
    });

    it("watches a dialog that is open when the hook starts", async () => {
      hook.destroy();
      el.showModal();
      hook = initDialog(el, { execJS });
      el.showModal.mockClear();

      move(el);
      await settle();

      expect(el.showModal).toHaveBeenCalledOnce();
    });

    it("does not show a removed dialog", async () => {
      await open();

      el.remove();
      await settle();

      expect(el.showModal).not.toHaveBeenCalled();
    });

    it("stops watching once destroyed", async () => {
      await open();

      hook.destroy();
      move(el);
      await settle();

      expect(el.showModal).not.toHaveBeenCalled();
    });

    it("does not watch a dialog opened after it is destroyed", async () => {
      hook.destroy();
      el.showModal();
      await settle();
      el.showModal.mockClear();

      move(el);
      await settle();

      expect(el.showModal).not.toHaveBeenCalled();
    });

    describe("with a dialog opened over it", () => {
      let over;
      let overHook;

      beforeEach(() => {
        over = el.cloneNode(true);
        over.id = "over";
        document.body.append(over);
        fakeTopLayer(over);
        overHook = initDialog(over, { execJS });
      });

      afterEach(() => overHook.destroy());

      const openBoth = async () => {
        await open();
        dispatch(over, "doggo:open");
        await settle();
        over.showModal.mockClear();
      };

      it("keeps the dialog above on top", async () => {
        await openBoth();
        const inside = over.querySelectorAll("button")[1];
        inside.focus();

        move(el);
        await settle();

        expect(topLayer).toEqual([el, over]);
        expect(document.activeElement).toBe(inside);
      });

      it("shows each dialog again once when both move", async () => {
        const wrapper = document.createElement("div");
        document.body.append(wrapper);
        wrapper.append(el, over);
        await openBoth();

        move(wrapper);
        await settle();

        expect(topLayer).toEqual([el, over]);
        expect(el.showModal).toHaveBeenCalledOnce();
        expect(over.showModal).toHaveBeenCalledOnce();
      });

      it("keeps the order through repeated moves", async () => {
        await openBoth();

        move(el);
        await settle();
        move(el);
        await settle();

        expect(topLayer).toEqual([el, over]);
        expect(el.showModal).toHaveBeenCalledTimes(2);
        expect(over.showModal).toHaveBeenCalledTimes(2);
      });

      it("leaves the dialog above alone when the one below is removed", async () => {
        await openBoth();

        el.remove();
        await settle();

        expect(over.showModal).not.toHaveBeenCalled();
      });

      it("leaves the dialog above alone once the one below is destroyed", async () => {
        await openBoth();

        hook.destroy();
        move(el);
        await settle();

        expect(el.showModal).not.toHaveBeenCalled();
        expect(over.showModal).not.toHaveBeenCalled();
      });

      it("leaves the dialog below alone when the one above moves", async () => {
        await openBoth();

        move(over);
        await settle();

        expect(el.showModal).not.toHaveBeenCalled();
        expect(topLayer).toEqual([el, over]);
      });

      it("keeps the order when a closed dialog's hook mounts", async () => {
        await open();
        const closed = el.cloneNode(true);
        closed.id = "closed";
        document.body.append(closed);
        initDialog(closed).destroy();

        move(el);
        await settle();

        expect(el.showModal).toHaveBeenCalledOnce();
      });

      it("shows the dialogs above when one of them fails", async () => {
        const reportError = vi.fn();
        vi.stubGlobal("reportError", reportError);
        const third = el.cloneNode(true);
        third.id = "third";
        document.body.append(third);
        fakeTopLayer(third);
        const thirdHook = initDialog(third, { execJS });
        await openBoth();
        dispatch(third, "doggo:open");
        await settle();
        over.showModal.mockImplementation(() => {
          throw new Error("failed");
        });

        move(el);
        await settle();

        expect(reportError).toHaveBeenCalledOnce();
        expect(topLayer).toEqual([el, third]);
        thirdHook.destroy();
        vi.unstubAllGlobals();
      });

      it("leaves out a dialog that closed", async () => {
        await openBoth();
        over.close();
        await settle();

        move(el);
        await settle();

        expect(over.showModal).not.toHaveBeenCalled();
        expect(topLayer).toEqual([el]);
      });

      it("leaves out a dialog that was removed", async () => {
        await openBoth();
        over.remove();
        await settle();

        move(el);
        await settle();

        expect(over.showModal).not.toHaveBeenCalled();
        expect(topLayer).toEqual([el]);
      });

      it("leaves out a dialog whose hook was destroyed", async () => {
        await openBoth();
        overHook.destroy();

        move(el);
        await settle();

        expect(over.showModal).not.toHaveBeenCalled();
      });

      it("leaves out a dialog opened without showModal", async () => {
        await open();
        over.setAttribute("open", "");
        await settle();

        move(el);
        await settle();

        expect(over.showModal).not.toHaveBeenCalled();
      });
    });
  });

  describe("without the command attribute", () => {
    it("opens from a button outside the dialog", () => {
      const opener = document.createElement("button");
      opener.setAttribute("command", "show-modal");
      opener.setAttribute("commandfor", el.id);
      document.body.appendChild(opener);

      opener.click();

      expect(el.open).toBe(true);
    });

    it("ignores an opener pointed at another dialog", () => {
      const opener = document.createElement("button");
      opener.setAttribute("command", "show-modal");
      opener.setAttribute("commandfor", "another-dialog");
      document.body.appendChild(opener);

      opener.click();

      expect(el.open).toBe(false);
    });

    it("ignores a command it does not implement", () => {
      const opener = document.createElement("button");
      opener.setAttribute("command", "toggle-popover");
      opener.setAttribute("commandfor", el.id);
      document.body.appendChild(opener);

      opener.click();

      expect(el.open).toBe(false);
    });

    it("stops listening on the document when the hook is destroyed", () => {
      const opener = document.createElement("button");
      opener.setAttribute("command", "show-modal");
      opener.setAttribute("commandfor", el.id);
      document.body.appendChild(opener);

      hook.destroy();
      opener.click();

      expect(el.open).toBe(false);
    });

    it("closes on the close button", () => {
      dispatch(el, "doggo:open");
      el.querySelector("button[command='close']").click();

      expect(el.open).toBe(false);
    });

    it("closes on a click inside the close button", () => {
      dispatch(el, "doggo:open");
      el.querySelector("button[command='close'] span").click();

      expect(el.open).toBe(false);
    });

    it("ignores a close button pointed at another dialog", () => {
      const button = el.querySelector("button[command='close']");
      button.setAttribute("commandfor", "another-dialog");
      dispatch(el, "doggo:open");
      button.click();

      expect(el.open).toBe(true);
    });
  });

  it("leaves the buttons to the browser when it has command", () => {
    withSupport(window.HTMLButtonElement.prototype, "command", () => {
      const fresh = render(fixture);
      initDialog(fresh);
      dispatch(fresh, "doggo:open");
      fresh.querySelector("button[command='close']").click();

      expect(fresh.open).toBe(true);
    });
  });

  describe("without the closedby attribute", () => {
    it("closes on a click outside", () => {
      dispatch(el, "doggo:open");
      el.click();

      expect(el.open).toBe(false);
    });

    it("stays open on a click inside", () => {
      dispatch(el, "doggo:open");
      el.querySelector("h2").click();

      expect(el.open).toBe(true);
    });

    it("stays open on a click outside with closerequest", () => {
      el.setAttribute("closedby", "closerequest");
      dispatch(el, "doggo:open");
      el.click();

      expect(el.open).toBe(true);
    });

    it("lets Escape through with closerequest", () => {
      el.setAttribute("closedby", "closerequest");
      dispatch(el, "doggo:open");
      const event = new window.Event("cancel", { cancelable: true });
      el.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
    });

    it("stays open on a click outside with none", () => {
      el.setAttribute("closedby", "none");
      dispatch(el, "doggo:open");
      el.click();

      expect(el.open).toBe(true);
    });

    it("holds Escape with none", () => {
      el.setAttribute("closedby", "none");
      dispatch(el, "doggo:open");
      const event = new window.Event("cancel", { cancelable: true });
      el.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
    });

    it("lets Escape through with any", () => {
      dispatch(el, "doggo:open");
      const event = new window.Event("cancel", { cancelable: true });
      el.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
    });
  });

  it("leaves dismissal to the browser when it has closedBy", () => {
    withSupport(window.HTMLDialogElement.prototype, "closedBy", () => {
      const fresh = render(fixture);
      initDialog(fresh);
      dispatch(fresh, "doggo:open");
      fresh.click();

      expect(fresh.open).toBe(true);
    });
  });
});
