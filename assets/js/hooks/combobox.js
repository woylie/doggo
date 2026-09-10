import { stepIndex } from "../navigation.js";

const OPTIONS = '[role="option"]';

export function initCombobox(combobox) {
  const input = combobox.querySelector('[role="combobox"]');
  const listbox = document.getElementById(input.getAttribute("aria-controls"));
  const toggle = combobox.querySelector("button");
  const hidden = combobox.querySelector('input[type="hidden"]');

  const serverFiltering = combobox.dataset.filter === "server";

  let activeIdx = null;

  // Open state of the listbox, owned by the hook.
  let isOpen = false;

  // The display value for the current selection.
  let displayValue = input.value;

  // The value that the form submits, owned by the server.
  let submitValue = hidden.value;

  const options = () => Array.from(listbox.querySelectorAll(OPTIONS));

  const visibleOptions = () => options().filter((option) => !option.hidden);

  const label = (option) =>
    option.querySelector("span")?.textContent.trim() ?? "";

  const inert = () => input.readOnly || input.disabled;

  const reflect = () => {
    listbox.hidden = !isOpen;
    input.setAttribute("aria-expanded", String(isOpen));
    toggle?.setAttribute("aria-expanded", String(isOpen));
  };

  // An option is selected while it is active, following the ARIA Authoring
  // Practices. If no option is active, the option with the submit value is
  // selected.
  const markSelected = () => {
    const active = activeIdx === null ? null : visibleOptions()[activeIdx];

    options().forEach((option) => {
      const selected = active
        ? option === active
        : option.dataset.value === submitValue;

      option.setAttribute("aria-selected", String(selected));
    });
  };

  const setActive = (idx) => {
    const visible = visibleOptions();
    activeIdx = idx === null || visible.length === 0 ? null : idx;

    if (activeIdx === null) {
      input.removeAttribute("aria-activedescendant");
    } else {
      input.setAttribute("aria-activedescendant", visible[activeIdx].id);
      visible[activeIdx].scrollIntoView({ block: "nearest" });
    }

    markSelected();
  };

  // Returns the index of the visible option for the submit value.
  const submitValueIdx = () => {
    const idx = visibleOptions().findIndex(
      (option) => option.dataset.value === submitValue,
    );

    return idx === -1 ? null : idx;
  };

  const open = () => {
    if (inert() || visibleOptions().length === 0) return;

    isOpen = true;
    reflect();
  };

  const close = () => {
    isOpen = false;
    reflect();
    setActive(null);
  };

  const commit = (value, text) => {
    displayValue = text;
    submitValue = value;
    hidden.value = value;
    input.value = text;

    // Changing the value of the hidden input on its own does not trigger a
    // `phx-change` event. We need to dispatch one manually.
    hidden.dispatchEvent(new Event("input", { bubbles: true }));
  };

  const select = (option) => {
    if (inert()) return;

    // Replace search term in the input value with the selected value.
    commit(option.dataset.value, label(option));

    // Update the filtered options based on the new input value.
    filter();
    close();
  };

  const filter = () => {
    if (serverFiltering) return;

    const term = input.value.trim();
    const needle = term.toLowerCase();

    // The display value of the current selection is not a search term and
    // should not filter the options.
    const searching = term !== displayValue.trim();

    options().forEach((option) => {
      option.hidden =
        searching &&
        needle !== "" &&
        !label(option).toLowerCase().includes(needle);
    });
  };

  // Handles the `Up` (offset=-1) and `Down` (offset=1) keys.
  const move = (offset) => {
    // If the listbox is closed, open it and move to the index of the submit
    // value or to the first or last item depending on the offset.
    if (!isOpen) {
      open();

      // The listbox is not opened if the input is disabled or readonly, so we
      // need to check the state after calling `open()`.
      if (isOpen) {
        const from = submitValueIdx();

        // If there is a submit value: Move to that index.
        // If offset=-1 (arrow up): Move to the last index.
        // If offset=1 (arrow down): Move to the first index.
        setActive(
          from === null ? (offset > 0 ? 0 : visibleOptions().length - 1) : from,
        );
      }

      return;
    }

    // If the listbox is already open, move by one from the active index, or
    // if there is no active index, move to the first or last item depending
    // on the given offset.

    const total = visibleOptions().length;
    if (total === 0) return;

    const from = activeIdx === null ? (offset > 0 ? -1 : total) : activeIdx;
    setActive(stepIndex(from, offset, total));
  };

  input.addEventListener("keydown", (e) => {
    if (inert()) return;

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault();
        if (e.altKey) open();
        else move(1);
        break;
      case "ArrowUp":
        e.preventDefault();
        move(-1);
        break;
      case "Enter":
        if (!isOpen || activeIdx === null) return;
        e.preventDefault();
        select(visibleOptions()[activeIdx]);
        break;
      case "Tab":
        if (isOpen && activeIdx !== null) select(visibleOptions()[activeIdx]);
        break;
      case "Escape": {
        let handled = false;

        // If the listbox is open or if the display value is a search term
        // (as opposed to the display value of the selection), reset the
        // input value to the display value of the selection and reset the
        // option filter.
        // If the listbox is closed and there is a selection, reset it.
        if (isOpen || input.value.trim() !== displayValue.trim()) {
          input.value = displayValue;
          filter();
          close();
          handled = true;
        } else if (input.value !== "" || submitValue !== "") {
          commit("", "");
          filter();
          markSelected();
          handled = true;
        }

        // Only prevent default and stop propagation if the `Escape` key had an
        // effect on the component.
        if (handled) {
          e.preventDefault();
          e.stopPropagation();
        }

        break;
      }
    }
  });

  input.addEventListener("input", () => {
    filter();
    setActive(null);

    if (visibleOptions().length === 0) close();
    else open();
  });

  toggle?.addEventListener("click", () => {
    if (isOpen) close();
    else open();

    input.focus();
  });

  // Keep focus in the input, so that typing keeps working when the listbox is
  // open.
  listbox.addEventListener("mousedown", (e) => e.preventDefault());

  listbox.addEventListener("click", (e) => {
    const option = e.target.closest(OPTIONS);
    if (option && !option.hidden) select(option);
  });

  combobox.addEventListener("focusout", (e) => {
    if (combobox.contains(e.relatedTarget)) return;
    close();
  });

  filter();
  markSelected();

  return {
    // A patch restores the listbox's `hidden` attribute and may have replaced
    // the options. Re-apply open state with `reflect()` and apply filters on
    // the potentially new options. Reset active index, since it may be stale
    // if the options changed.
    update() {
      // The server owns the hidden input value. Set the internal submit value
      // to the value of the hidden input.
      submitValue = hidden.value;

      // The server only owns the display value while the input is not focused.
      // LiveView does not patch focused inputs.
      if (document.activeElement !== input) displayValue = input.value;

      filter();
      setActive(null);

      if (isOpen && visibleOptions().length === 0) close();
      else reflect();
    },
  };
}

export default {
  mounted() {
    this.instance = initCombobox(this.el);
  },
  updated() {
    this.instance.update();
  },
};
