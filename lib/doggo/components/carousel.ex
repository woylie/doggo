defmodule Doggo.Components.Carousel do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a carousel for presenting a sequence of items, such as images or text.
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
  def css_path do
    "components/_carousel.scss"
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - Handle pagination tabs
      - Auto rotation
      - Disable auto rotation when controls are used
      - Disable previous/next button on first/last item.
      - Focus management and keyboard support for pagination
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
      attr :pagination_label, :string, default: "Slides"

      attr :pagination_slide_label, :any,
        default: &Doggo.slide_label/1,
        doc: """
        1-arity function that takes the slide number as an argument and returns the
        aria label for the pagination tab of a slide that has no `label` of its
        own.
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

    ~H"""
    <section
      id={@id}
      class={@class}
      aria-label={@label}
      aria-labelledby={@labelledby}
      aria-roledescription={@carousel_roledescription}
      data-active-index="0"
      {@data_attrs}
      {@rest}
      phx-hook=".Hook"
    >
      <div class={"#{@base_class}-inner"}>
        <div class={"#{@base_class}-controls"}>
          <button
            :for={previous <- @previous}
            type="button"
            class={"#{@base_class}-previous"}
            aria-controls={"#{@id}-items"}
            aria-label={previous.label}
          >
            {render_slot(previous)}
          </button>
          <button
            :for={next <- @next}
            type="button"
            class={"#{@base_class}-next"}
            aria-controls={"#{@id}-items"}
            aria-label={next.label}
          >
            {render_slot(next)}
          </button>
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
          <div
            :if={@pagination}
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
        </div>
        <div class={"#{@base_class}-items-container"}>
          <div
            id={"#{@id}-items"}
            class={"#{@base_class}-items"}
            aria-live={if @pause == [], do: "polite", else: "off"}
          >
            <div
              :for={{item, index} <- Enum.with_index(@item, 1)}
              id={"#{@id}-item-#{index}"}
              class={"#{@base_class}-item"}
              role={if @pagination, do: "tabpanel", else: "group"}
              aria-roledescription={@slide_roledescription}
              aria-label={if not @pagination, do: item[:label]}
              aria-labelledby={@pagination && "#{@id}-tab-#{index}"}
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

          const prevBtn = carousel.querySelector(`.${baseClass}-previous`);
          const nextBtn = carousel.querySelector(`.${baseClass}-next`);
          const pauseBtn = carousel.querySelector(`.${baseClass}-pause`);
          const liveRegion = carousel.querySelector(`.${baseClass}-items`);
          const tabs = carousel.querySelectorAll(
            `.${baseClass}-pagination [role="tab"]`
          );
          const itemsContainer =
            carousel.querySelector(`.${baseClass}-items-container`);
          const items = carousel.querySelectorAll(`.${baseClass}-item`);
          const totalItems = items.length;

          const isAutoRotationEnabled = pauseBtn != null;
          const rotationIntervalMs = 5000;
          let autoRotationTimer = null;

          const getWrappedIndex = (currentIdx, offset) => {
            return (currentIdx + offset + totalItems) % totalItems;
          };

          const getCurrentIdx = () =>
            Number(carousel.getAttribute("data-active-index")) || 0;

          const getActiveIdx = () => {
            const viewport = itemsContainer.getBoundingClientRect();
            const viewportCenter = viewport.left + viewport.width / 2;

            let activeIdx = 0;
            let shortestDistance = Infinity;

            items.forEach((item, idx) => {
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
            carousel.setAttribute("data-active-index", activeIdx);

            tabs.forEach((tab, idx) => {
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
            const item = items[idx];

            if (!item) return;

            setActiveIdx(idx);

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

          itemsContainer.addEventListener("scroll", syncActiveState);

          if (prevBtn) {
            prevBtn.addEventListener("click", () => {
              pauseForInteraction();
              scrollToIdx(getWrappedIndex(getCurrentIdx(), -1));
            });
          }

          if (nextBtn) {
            nextBtn.addEventListener("click", () => {
              pauseForInteraction();
              scrollToIdx(getWrappedIndex(getCurrentIdx(), 1));
            });
          }

          tabs.forEach((tab, idx) => {
            tab.addEventListener("click", () => {
              pauseForInteraction();
              scrollToIdx(idx);
            });

            // Selection follows the focus, so moving between the tabs moves
            // the carousel with them.
            tab.addEventListener("keydown", (e) => {
              let nextIdx;

              if (e.key === "ArrowRight") {
                nextIdx = getWrappedIndex(getCurrentIdx(), 1);
              } else if (e.key === "ArrowLeft") {
                nextIdx = getWrappedIndex(getCurrentIdx(), -1);
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
              tabs[nextIdx].focus();
            });
          });

          // Auto rotation
          let isPaused = false;

          const startAutoRotation = () => {
            if (!isAutoRotationEnabled || isPaused) return;
            if (autoRotationTimer != null) return;

            autoRotationTimer = setInterval(() => {
              scrollToIdx(getWrappedIndex(getCurrentIdx(), 1));
            }, rotationIntervalMs);
          }

          const stopAutoRotation = () => {
            if (autoRotationTimer != null) {
              clearInterval(autoRotationTimer);
              autoRotationTimer = null;
            }
          }

          // The control keeps its position and swaps its name, which is what
          // the APG recommends for a rotation control.
          const syncPauseControl = () => {
            carousel.toggleAttribute("data-paused", isPaused);

            // A slide arriving on a timer is noise, but one the reader asked
            // for is worth announcing, so the live region follows the rotation.
            if (isAutoRotationEnabled && liveRegion) {
              liveRegion.setAttribute("aria-live", isPaused ? "polite" : "off");
            }

            if (!pauseBtn) return;

            const label = isPaused
              ? pauseBtn.dataset.resumeLabel
              : pauseBtn.dataset.pauseLabel;

            if (label) pauseBtn.setAttribute("aria-label", label);
          }

          // The APG asks that using a control stops the rotation, so the
          // carousel does not move on under the reader while they are using it.
          const pauseForInteraction = () => {
            if (isPaused) return;

            isPaused = true;
            stopAutoRotation();
            syncPauseControl();
          };

          if (pauseBtn) {
            pauseBtn.addEventListener("click", () => {
              isPaused = !isPaused;
              isPaused ? stopAutoRotation() : startAutoRotation();
              syncPauseControl();
            });
          }

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
        }
      }
    </script>
    """
  end
end
