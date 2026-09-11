import { stepIndex } from "../navigation.js";

const OPTIONS = '[role="option"]';
const GROUPS = '[role="group"]';
const SEPARATORS = "hr";

let cachedNoSelectionMessage;

const noSelectionMessage = () => {
  if (cachedNoSelectionMessage === undefined) {
    const select = document.createElement("select");
    select.required = true;
    cachedNoSelectionMessage = select.validationMessage;
  }

  return cachedNoSelectionMessage;
};

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

  const isDisabled = (option) =>
    option.getAttribute("aria-disabled") === "true";

  const navigableOptions = () => visibleOptions().filter((o) => !isDisabled(o));

  const freeTextOption = () => listbox.querySelector("[data-free-text]");

  const optionValue = (option) =>
    option.hasAttribute("data-free-text") ? null : option.dataset.value;

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
    const active = activeIdx === null ? null : navigableOptions()[activeIdx];

    options().forEach((option) => {
      const selected = active
        ? option === active
        : optionValue(option) === submitValue;

      option.setAttribute("aria-selected", String(selected));
    });
  };

  const setActive = (idx) => {
    const visible = navigableOptions();
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
    const idx = navigableOptions().findIndex(
      (option) => optionValue(option) === submitValue,
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

  const validate = () => {
    const missing = submitValue === "";
    const typed = input.value.trim() !== "";

    input.setCustomValidity(
      input.required && missing && typed ? noSelectionMessage() : "",
    );
  };

  const commit = (value, text) => {
    displayValue = text;
    submitValue = value;
    hidden.value = value;
    input.value = text;

    // Changing the value of the hidden input on its own does not trigger a
    // `phx-change` event. We need to dispatch one manually.
    hidden.dispatchEvent(new Event("input", { bubbles: true }));
    validate();
  };

  const select = (option) => {
    if (inert() || isDisabled(option)) return;

    // Replace search term in the input value with the selected value. The free
    // text option submits the typed term itself.
    if (option.hasAttribute("data-free-text")) {
      const term = input.value.trim();
      commit(term, term);
    } else {
      commit(option.dataset.value, label(option));
    }

    // Update the filtered options based on the new input value.
    filter();
    close();
  };

  const filter = () => {
    const term = input.value.trim();
    const needle = term.toLowerCase();
    const free = freeTextOption();

    // The display value of the current selection is not a search term and
    // should not filter the options.
    const searching = term !== displayValue.trim();

    if (!serverFiltering) {
      options().forEach((option) => {
        if (option === free) return;

        option.hidden =
          searching &&
          needle !== "" &&
          !label(option).toLowerCase().includes(needle);
      });

      // Hide groups without visible options.
      listbox.querySelectorAll(GROUPS).forEach((group) => {
        group.hidden = !Array.from(group.querySelectorAll(OPTIONS)).some(
          (option) => !option.hidden,
        );
      });

      // Separators structure the full list only.
      const filtering = searching && needle !== "";

      listbox
        .querySelectorAll(SEPARATORS)
        .forEach((separator) => (separator.hidden = filtering));
    }

    if (free) {
      const exists = options().some(
        (option) => option !== free && label(option).toLowerCase() === needle,
      );

      free.hidden = !searching || term === "" || exists;
      free.querySelector("span + span").textContent = free.hidden ? "" : term;
    }
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
          from === null
            ? offset > 0
              ? 0
              : navigableOptions().length - 1
            : from,
        );
      }

      return;
    }

    // If the listbox is already open, move by one from the active index, or
    // if there is no active index, move to the first or last item depending
    // on the given offset.

    const total = navigableOptions().length;
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
        select(navigableOptions()[activeIdx]);
        break;
      case "Tab":
        if (isOpen && activeIdx !== null) select(navigableOptions()[activeIdx]);
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
    validate();

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
  validate();

  return {
    // A patch restores the listbox's `hidden` attribute and may have replaced
    // the options. Re-apply open state with `reflect()` and apply filters on
    // the potentially new options. Reset active index, since it may be stale
    // if the options changed.
    update() {
      // The server owns the hidden input value. Set the internal submit value
      // to the value of the hidden input.
      submitValue = hidden.value;
      validate();

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
