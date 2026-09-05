import { beforeEach, describe, expect, it, vi } from "vitest";
import { initDialog } from "../js/hooks/dialog.js";
import fixture from "./fixtures/modal.html?raw";
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

describe("dialog hook", () => {
  let el;
  let hook;
  let execJS;

  beforeEach(() => {
    el = render(fixture);
    execJS = vi.fn();
    hook = initDialog(el, { execJS });
  });

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

  it("runs on_cancel when the dialog closes, however it was closed", () => {
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

    it("closes on a click inside the close button, not only on it", () => {
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
    it("closes on a click outside, which lands on the dialog itself", () => {
      dispatch(el, "doggo:open");
      el.click();

      expect(el.open).toBe(false);
    });

    it("stays open on a click inside", () => {
      dispatch(el, "doggo:open");
      el.querySelector("h2").click();

      expect(el.open).toBe(true);
    });

    it("stays open on a click outside when it is not dismissable", () => {
      el.setAttribute("closedby", "none");
      dispatch(el, "doggo:open");
      el.click();

      expect(el.open).toBe(true);
    });

    it("holds Escape when it is not dismissable", () => {
      el.setAttribute("closedby", "none");
      dispatch(el, "doggo:open");
      const event = new window.Event("cancel", { cancelable: true });
      el.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
    });

    it("lets Escape through when it is dismissable", () => {
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
