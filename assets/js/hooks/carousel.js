export default {
  mounted() {
    const carousel = this.el;
    const baseClass = carousel.className.split(" ")[0];

    const getItemsContainer = () =>
      carousel.querySelector(`.${baseClass}-items-container`);

    const getLiveRegion = () => carousel.querySelector(`.${baseClass}-items`);

    const getItems = () =>
      Array.from(getItemsContainer().querySelectorAll(`.${baseClass}-item`));

    const getTabs = () =>
      Array.from(
        carousel.querySelectorAll(`.${baseClass}-pagination [role="tab"]`),
      );

    const getControl = (name) =>
      carousel.querySelector(`.${baseClass}-${name}`);

    // Auto rotation is enabled if there is a pause button.
    const isAutoRotationEnabled = () => getControl("pause") != null;
    // Ignore a non-positive interval.
    const interval = Number(carousel.dataset.rotationIntervalMs);
    const rotationIntervalMs = interval > 0 ? interval : 5000;
    let autoRotationTimer = null;

    const isLoopEnabled = carousel.getAttribute("data-loop") != null;

    const getTargetIdx = (currentIdx, offset) => {
      const total = getItems().length;

      if (isLoopEnabled) {
        return (currentIdx + offset + total) % total;
      }

      return Math.min(Math.max(currentIdx + offset, 0), total - 1);
    };

    const getCurrentIdx = () =>
      Number(carousel.getAttribute("data-active-index")) || 0;

    const setDisabled = (el, disabled) => {
      if (!el) return;

      if (disabled) {
        el.setAttribute("disabled", "");
      } else {
        el.removeAttribute("disabled");
      }
    };

    const getActiveIdx = () => {
      const viewport = getItemsContainer().getBoundingClientRect();
      const viewportCenter = viewport.left + viewport.width / 2;

      let activeIdx = 0;
      let shortestDistance = Infinity;

      getItems().forEach((item, idx) => {
        const rect = item.getBoundingClientRect();
        const center = rect.left + rect.width / 2;
        const distance = Math.abs(center - viewportCenter);

        if (distance < shortestDistance) {
          shortestDistance = distance;
          activeIdx = idx;
        }
      });

      return activeIdx;
    };

    const setActiveIdx = (activeIdx) => {
      const items = getItems();

      carousel.setAttribute("data-active-index", activeIdx);

      if (!isLoopEnabled) {
        setDisabled(getControl("previous"), activeIdx === 0);
        setDisabled(getControl("next"), activeIdx === items.length - 1);
      }

      getTabs().forEach((tab, idx) => {
        const isSelected = idx === activeIdx;
        tab.setAttribute("aria-selected", isSelected ? "true" : "false");
        tab.setAttribute("tabindex", isSelected ? "0" : "-1");
      });

      items.forEach((item, idx) => {
        item.setAttribute("aria-current", idx === activeIdx ? "true" : "false");
      });
    };

    const syncActiveState = () => setActiveIdx(getActiveIdx());

    const scrollToIdx = (idx) => {
      const item = getItems()[idx];

      if (!item) return;

      setActiveIdx(idx);

      const itemsContainer = getItemsContainer();
      const container = itemsContainer.getBoundingClientRect();
      const target = item.getBoundingClientRect();
      const offset =
        target.left + target.width / 2 - (container.left + container.width / 2);

      const maxScroll = itemsContainer.scrollWidth - itemsContainer.clientWidth;

      itemsContainer.scrollLeft = Math.min(
        Math.max(itemsContainer.scrollLeft + offset, 0),
        maxScroll,
      );
    };

    // Auto rotation
    let isPaused = false;

    // Stop auto rotation if the last items does not wrap.
    const hasShowEnded = () =>
      !isLoopEnabled && getCurrentIdx() === getItems().length - 1;

    const endShow = () => {
      isPaused = true;
      stopAutoRotation();
      syncPauseControl();
    };

    const startAutoRotation = () => {
      if (!isAutoRotationEnabled() || isPaused) return;
      if (autoRotationTimer != null) return;

      if (hasShowEnded()) {
        endShow();
        return;
      }

      autoRotationTimer = setInterval(() => {
        scrollToIdx(getTargetIdx(getCurrentIdx(), 1));

        if (hasShowEnded()) endShow();
      }, rotationIntervalMs);
    };

    const stopAutoRotation = () => {
      if (autoRotationTimer != null) {
        clearInterval(autoRotationTimer);
        autoRotationTimer = null;
      }
    };

    // The pause button changes its label, not its position.
    const syncPauseControl = () => {
      const pauseBtn = getControl("pause");

      carousel.toggleAttribute("data-paused", isPaused);

      // Announce slide changes only while auto rotation is stopped.
      const liveRegion = getLiveRegion();

      if (isAutoRotationEnabled() && liveRegion) {
        liveRegion.setAttribute("aria-live", isPaused ? "polite" : "off");
      }

      if (!pauseBtn) return;

      const label = isPaused
        ? pauseBtn.dataset.resumeLabel
        : pauseBtn.dataset.pauseLabel;

      if (label) pauseBtn.setAttribute("aria-label", label);
    };

    // Using any control stops auto rotation.
    const pauseForInteraction = () => {
      if (isPaused) return;

      isPaused = true;
      stopAutoRotation();
      syncPauseControl();
    };

    const togglePause = () => {
      isPaused = !isPaused;

      if (isPaused) {
        stopAutoRotation();
      } else {
        // If looped=false and we're on the last slide, toggling the
        // resume button starts the slide show on the first slide again.
        if (hasShowEnded()) scrollToIdx(0);

        startAutoRotation();
      }

      syncPauseControl();
    };

    carousel.addEventListener(
      "scroll",
      (e) => {
        if (e.target === getItemsContainer()) syncActiveState();
      },
      true,
    );

    // Event listener is added on the carousel instead of the buttons
    // because a patch can replace the buttons, which would remove the
    // listeners.
    carousel.addEventListener("click", (e) => {
      const control = e.target.closest(
        `.${baseClass}-previous, .${baseClass}-next,` +
          ` .${baseClass}-pause, .${baseClass}-pagination [role="tab"]`,
      );

      if (!control) return;

      if (control.matches(`.${baseClass}-pause`)) {
        togglePause();
        return;
      }

      pauseForInteraction();

      if (control.matches(`.${baseClass}-previous`)) {
        scrollToIdx(getTargetIdx(getCurrentIdx(), -1));
      } else if (control.matches(`.${baseClass}-next`)) {
        scrollToIdx(getTargetIdx(getCurrentIdx(), 1));
      } else {
        const idx = getTabs().indexOf(control);

        if (idx >= 0) scrollToIdx(idx);
      }
    });

    carousel.addEventListener("keydown", (e) => {
      const tab = e.target.closest(`.${baseClass}-pagination [role="tab"]`);

      if (!tab) return;

      const tabs = getTabs();
      let nextIdx;

      if (e.key === "ArrowRight") {
        nextIdx = getTargetIdx(getCurrentIdx(), 1);
      } else if (e.key === "ArrowLeft") {
        nextIdx = getTargetIdx(getCurrentIdx(), -1);
      } else if (e.key === "Home") {
        nextIdx = 0;
      } else if (e.key === "End") {
        nextIdx = tabs.length - 1;
      } else {
        return;
      }

      e.preventDefault();
      pauseForInteraction();
      scrollToIdx(nextIdx);

      if (tabs[nextIdx]) tabs[nextIdx].focus();
    });

    // Pause when hovering or focusing, resume when leaving, unless
    // rotation is paused with the pause button.
    carousel.addEventListener("pointerenter", stopAutoRotation);
    carousel.addEventListener("pointerleave", startAutoRotation);
    carousel.addEventListener("focusin", stopAutoRotation);

    carousel.addEventListener("focusout", (e) => {
      // focusout also fires while focus moves between controls inside
      // the carousel, and that must not resume the rotation.
      if (!carousel.contains(e.relatedTarget)) startAutoRotation();
    });

    // Initialize
    syncActiveState();
    syncPauseControl();
    startAutoRotation();

    this.syncAfterUpdate = () => {
      syncActiveState();
      syncPauseControl();

      // A patch can add or remove the pause button, and with it the
      // rotation. Starting is a no-op while it runs or is paused.
      if (isAutoRotationEnabled()) {
        startAutoRotation();
      } else {
        stopAutoRotation();
      }
    };
  },

  // A patch can add or remove slides. Recompute which slide is active,
  // and set the pause button label and the disabled buttons again.
  updated() {
    this.syncAfterUpdate();
  },
};
