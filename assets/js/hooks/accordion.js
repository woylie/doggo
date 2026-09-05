import { targetIndex } from "../navigation.js";

export default {
  mounted() {
    const accordion = this.el;

    // Read on demand, so that headers added by a patch are found.
    const getHeaders = () =>
      Array.from(accordion.querySelectorAll("button[aria-expanded]")).filter(
        (header) =>
          header.closest('[phx-hook="Doggo.Accordion"]') === accordion,
      );

    accordion.addEventListener("keydown", (e) => {
      const headers = getHeaders();
      const currentIdx = headers.indexOf(
        e.target.closest("button[aria-expanded]"),
      );

      if (currentIdx < 0) return;

      const nextIdx = targetIndex(e.key, currentIdx, headers.length, {
        orientation: "vertical",
      });

      if (nextIdx === null) return;

      e.preventDefault();
      headers[nextIdx].focus();
    });
  },
};
