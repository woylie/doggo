defmodule Doggo.Components.Carousel do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a carousel for presenting a sequence of items, such as images or text.

    If a carousel only has a single item, no controls and no pagination are
    rendered.

    ## Required CSS

    The element with the `-items-container` class has to be a horizontal scroll
    container, since the controls and the auto rotation move the carousel by
    scrolling it:

    ```css
    .carousel-items-container {
      overflow-x: auto;
      scroll-snap-type: x mandatory;
    }

    .carousel-items {
      display: flex;
    }

    .carousel-item {
      flex: 0 0 100%;
      scroll-snap-align: center;
    }
    ```

    The items must not shrink. Scroll snapping is optional, but without it a
    slide can come to rest half shown. Whether the movement is animated
    depends on `scroll-behavior`. If you animate it, turn it off with a
    `@media (prefers-reduced-motion)` media query.

    ## Styling

    The carousel has a `data-active-index` attribute, and `data-paused` while
    the rotation is stopped. The visible slide has `aria-current`, its
    pagination tab has `aria-selected`, and with `loop={false}` the previous and
    next buttons are `disabled` at the ends.

    The pause button changes its label, not its content. Put both icons into the
    slot and use a CSS selector on `data-paused` to pick one:

    ```heex
    <:pause label="Pause slide show" resume_label="Resume slide show">
      <.icon name="pause" class="when-running" />
      <.icon name="play" class="when-paused" />
    </:pause>
    ```

    ```css
    .carousel:not([data-paused]) .when-paused,
    .carousel[data-paused] .when-running {
      display: none;
    }
    ```

    ## Localization

    `carousel_roledescription`, `slide_roledescription`, `pagination_label` and
    the labels of the `:pause` slot default to English. They are announced by
    screen readers and should be translated. The `pagination_slide_label` and
    the labels of the `:previous` and `:next` slots should also be translated.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.carousel label="Our Dogs">
      <:previous label="Previous Slide">
        <Heroicons.chevron_left />
      </:previous>
      <:next label="Next Slide">
        <Heroicons.chevron_right />
      </:next>
      <:item label="1 of 3">
        <.image
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt="A dog wearing a colorful poncho walks down a fashion show runway."
          ratio={{16, 9}}
        />
      </:item>
      <:item label="2 of 3">
        <.image
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt="A dog dressed in a sumptuous, baroque-style costume, complete with jewels and intricate embroidery, parades on an ornate runway at a luxurious fashion show, embodying opulence and grandeur."
          ratio={{16, 9}}
        />
      </:item>
      <:item label="3 of 3">
        <.image
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt="A dog adorned in a lavish, flamboyant outfit, including a large feathered hat and elaborate jewelry, struts confidently down a luxurious fashion show runway, surrounded by bright lights and an enthusiastic audience."
          ratio={{16, 9}}
        />
      </:item>
    </.carousel>
    ```

    This component defines colocated Phoenix LiveView hook with the name
    `Doggo.Components.Carousel.Hook`.

    ```js
    import { hooks as doggoHooks } from "phoenix-colocated/doggo";

    const Hooks = {
      'Doggo.Components.Carousel.Hook': doggoHooks['Doggo.Components.Carousel.Hook']
    };

    const liveSocket = new LiveSocket("/live", Socket, {
      // ...
      hooks: Hooks,
    });
    ```
    """
  end

  @impl true
  def keyboard do
    """
    - `Left` and `Right` - previous or next slide, with the focus on a
      pagination tab. With `loop` they wrap, without it they stop at the ends.
    - `Home` and `End` - first or last slide, with the focus on a pagination
      tab.

    The pagination is a single tab stop. The arrow keys need the colocated hook.
    """
  end

  @impl true
  def css_path do
    "components/_carousel.scss"
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :developing,
      maturity_note: """
      The semantics follow the ARIA Authoring Practices. With `pagination`, the
      pickers are a tablist and the slides are its tab panels. Without it, the
      slides are groups.

      Everything the pattern asks for is implemented. The level stays at
      `:developing` because the API is new and has not been proven in production
      yet.
      """,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-controls",
      "#{base_class}-inner",
      "#{base_class}-item",
      "#{base_class}-items",
      "#{base_class}-items-container",
      "#{base_class}-next",
      "#{base_class}-pagination",
      "#{base_class}-pause",
      "#{base_class}-previous"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :label, :string,
        default: nil,
        doc: """
        A accessibility label for the carousel. Set as `aria-label` attribute.

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels this carousel.

        Example:

        ```html
        <h3 id="dog-carousel-label">Our Dogs</h3>
        <.carousel labelledby="dog-carousel-label"></.carousel>
        ```

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :carousel_roledescription, :string,
        default: "carousel",
        doc: """
        Sets the `aria-roledescription` attribute to describe the region as a
        carousel. This value should be translated to the language in which the rest
        of the page is displayed.
        """

      attr :slide_roledescription, :string,
        default: "slide",
        doc: """
        Sets the `aria-roledescription` attribute to describe a slide. This value
        should be translated to the language in which the rest of the page is
        displayed.
        """

      attr :pagination, :boolean, default: false

      attr :pagination_label, :string,
        default: "Slides",
        doc: """
        Labels the tablist of slide pickers. This value should be translated to
        the language in which the rest of the page is displayed.
        """

      attr :pagination_slide_label, :any,
        default: &Doggo.slide_label/1,
        doc: """
        1-arity function that takes the slide number as an argument and returns the
        aria label for the pagination tab of a slide that has no `label` of its
        own.
        """

      attr :rotation_interval_ms, :integer,
        default: 5000,
        doc: """
        How long each slide is shown. This only has an effect together with a
        `:pause` slot, because that's what enables auto rotation.
        """

      attr :loop, :boolean,
        default: true,
        doc: """
        If `true`, the previous and next controls move from the last item to the
        first and back.

        Set to `false` to stop at the ends instead. In that case, the previous
        and next are disabled on the first and last slide respectively, and the
        auto rotation stops on the last item; the pause control then starts the
        show again from the first item.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block,
        required: true,
        doc: """
        Place the `carousel_item/1` component here.
        """

      slot :previous do
        attr :label, :string
      end

      slot :next do
        attr :label, :string
      end

      slot :pause,
        doc: """
        A control that stops and restarts the automatic rotation.

        **Setting this slot is what enables the rotation.** WCAG 2.2.2 requires
        that content moving for more than five seconds can be paused, and a
        control with nothing to stop is a button that does nothing. Deriving
        one from the other makes both mistakes impossible.
        """ do
        attr :label, :string,
          doc: """
          Accessible name while the carousel is rotating. Defaults to
          `"Pause slide show"`. This value should be translated to the language
          in which the rest of the page is displayed.
          """

        attr :resume_label, :string,
          doc: """
          Accessible name once the carousel is paused. Defaults to
          `"Resume slide show"`. This value should be translated to the language
          in which the rest of the page is displayed.

          The control keeps its position and swaps its name, as the ARIA
          Authoring Practices recommend for a rotation control. It has no
          `aria-pressed` state.

          To show different slot content depending on the state, use the
          `.carousel[data-paused] .carousel-pause` and
          `.carousel:not([data-paused]) .carousel-pause` CSS selectors
          (assuming the default base class). See example CSS.
          """
      end

      slot :item, required: true do
        attr :label, :string,
          doc: """
          Aria label for the slide, e.g. "1 of 5". If `pagination` is `true`,
          the label is given to the tab that selects the slide, and the slide is
          labelled by that tab. Slides without a label fall back to
          `pagination_slide_label`.
          """
      end
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    Doggo.ensure_label!(assigns, ".carousel", "Our Dogs")

    multiple_items = length(assigns.item) > 1

    assigns =
      assign(assigns,
        multiple_items: multiple_items,
        show_tabs: assigns.pagination and multiple_items,
        rotating: assigns.pause != [] and multiple_items
      )

    ~H"""
    <section
      id={@id}
      class={@class}
      aria-label={@label}
      aria-labelledby={@labelledby}
      aria-roledescription={@carousel_roledescription}
      data-active-index="0"
      data-loop={@loop}
      data-rotation-interval-ms={@rotating && @rotation_interval_ms}
      {@data_attrs}
      {@rest}
      phx-hook=".Hook"
    >
      <div class={"#{@base_class}-inner"}>
        <div :if={@multiple_items} class={"#{@base_class}-controls"}>
          <button
            :for={pause <- @pause}
            type="button"
            class={"#{@base_class}-pause"}
            aria-controls={"#{@id}-items"}
            aria-label={pause[:label] || "Pause slide show"}
            data-pause-label={pause[:label] || "Pause slide show"}
            data-resume-label={pause[:resume_label] || "Resume slide show"}
          >
            {render_slot(pause)}
          </button>
          <button
            :for={previous <- @previous}
            type="button"
            class={"#{@base_class}-previous"}
            aria-controls={"#{@id}-items"}
            aria-label={previous.label}
            disabled={!@loop}
          >
            {render_slot(previous)}
          </button>
          <div
            :if={@show_tabs}
            class={"#{@base_class}-pagination"}
            role="tablist"
            aria-label={@pagination_label}
          >
            <button
              :for={{item, index} <- Enum.with_index(@item, 1)}
              type="button"
              role="tab"
              id={"#{@id}-tab-#{index}"}
              aria-selected={to_string(index == 1)}
              aria-controls={"#{@id}-item-#{index}"}
              aria-label={item[:label] || @pagination_slide_label.(index)}
              tabindex={index != 1 && "-1"}
            >
              <span></span>
            </button>
          </div>
          <button
            :for={next <- @next}
            type="button"
            class={"#{@base_class}-next"}
            aria-controls={"#{@id}-items"}
            aria-label={next.label}
          >
            {render_slot(next)}
          </button>
        </div>
        <div class={"#{@base_class}-items-container"}>
          <div
            id={"#{@id}-items"}
            class={"#{@base_class}-items"}
            aria-live={if @rotating, do: "off", else: "polite"}
          >
            <div
              :for={{item, index} <- Enum.with_index(@item, 1)}
              id={"#{@id}-item-#{index}"}
              class={"#{@base_class}-item"}
              role={if @show_tabs, do: "tabpanel", else: "group"}
              aria-roledescription={@slide_roledescription}
              aria-label={if not @show_tabs, do: item[:label]}
              aria-labelledby={@show_tabs && "#{@id}-tab-#{index}"}
            >
              {render_slot(item)}
            </div>
          </div>
        </div>
      </div>
    </section>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Hook">
      export default {
        mounted() {
          const carousel = this.el;
          const baseClass = carousel.className.split(' ')[0];

          const getItemsContainer = () =>
            carousel.querySelector(`.${baseClass}-items-container`);

          const getLiveRegion = () =>
            carousel.querySelector(`.${baseClass}-items`);

          const getItems = () =>
            Array.from(
              getItemsContainer().querySelectorAll(`.${baseClass}-item`)
            );

          const getTabs = () =>
            Array.from(
              carousel.querySelectorAll(`.${baseClass}-pagination [role="tab"]`)
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
              item.setAttribute("aria-current",
                idx === activeIdx ? "true" : "false"
              );
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
              target.left +
              target.width / 2 -
              (container.left + container.width / 2);

            const maxScroll =
              itemsContainer.scrollWidth - itemsContainer.clientWidth;

            itemsContainer.scrollLeft = Math.min(
              Math.max(itemsContainer.scrollLeft + offset, 0),
              maxScroll
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
          }

          const stopAutoRotation = () => {
            if (autoRotationTimer != null) {
              clearInterval(autoRotationTimer);
              autoRotationTimer = null;
            }
          }

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
          }

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
            true
          );

          // Event listener is added on the carousel instead of the buttons
          // because a patch can replace the buttons, which would remove the
          // listeners.
          carousel.addEventListener("click", (e) => {
            const control = e.target.closest(
              `.${baseClass}-previous, .${baseClass}-next,` +
                ` .${baseClass}-pause, .${baseClass}-pagination [role="tab"]`
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
            const tab = e.target.closest(
              `.${baseClass}-pagination [role="tab"]`
            );

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
          carousel.addEventListener('pointerenter', stopAutoRotation);
          carousel.addEventListener('pointerleave', startAutoRotation);
          carousel.addEventListener('focusin', stopAutoRotation);

          carousel.addEventListener('focusout', (e) => {
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
        }
      }
    </script>
    """
  end
end
