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
      "#{base_class}-next",
      "#{base_class}-pagination",
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
        aria label for the slide as used in the pagination buttons.
        """

      attr :auto_rotation, :boolean, default: false

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

      slot :item, required: true do
        attr :label, :string,
          doc: """
          Aria label for the slide, e.g. "1 of 5".
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
      data-auto-rotation={@auto_rotation}
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
          <div :if={@pagination} class={"#{@base_class}-pagination"}>
            <div role="tablist" aria-label={@pagination_label}>
              <button
                :for={{_, index} <- Enum.with_index(@item, 1)}
                type="button"
                role="tab"
                aria-label={@pagination_slide_label.(index)}
                aria-controls={"#{@id}-item-#{index}"}
              >
                <span><span></span></span>
              </button>
            </div>
          </div>
        </div>
        <div
          id={"#{@id}-items"}
          class={"#{@base_class}-items"}
          aria-live={if @auto_rotation, do: "off", else: "polite"}
        >
          <div
            :for={{item, index} <- Enum.with_index(@item, 1)}
            id={"#{@id}-item-#{index}"}
            class={"#{@base_class}-item"}
            role="group"
            aria-roledescription={@slide_roledescription}
            aria-label={item.label}
          >
            {render_slot(item)}
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
          const tabs = carousel.querySelectorAll('[role="tab"]');
          const itemsContainer = carousel.querySelector(`.${baseClass}-items`);
          const items = carousel.querySelectorAll(`.${baseClass}-item`);
          const totalItems = items.length;

          const isAutoRotationEnabled =
            carousel.getAttribute("data-auto-rotation") != null;
          const rotationIntervalMs = 5000;
          let autoRotationTimer = null;

          const getWrappedIndex = (currentIdx, offset) => {
            return (currentIdx + offset + totalItems) % totalItems;
          };

          const getCurrentIdx = () =>
            Number(carousel.getAttribute("data-active-index")) || 0;

          const syncActiveState = () => {
            const scrollLeft = itemsContainer.scrollLeft;
            const itemWidth = items[0].offsetWidth;

            const activeIdx = Math.round(scrollLeft / itemWidth);

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

          const scrollToIdx = (idx) => {
            itemsContainer.scrollTo({
              left: items[0].offsetWidth * idx,
              behavior: "smooth"
            });
          };

          itemsContainer.addEventListener("scroll", syncActiveState);

          if (prevBtn) {
            prevBtn.addEventListener("click", () => {
              scrollToIdx(getWrappedIndex(getCurrentIdx(), -1));
            });
          }

          if (nextBtn) {
            nextBtn.addEventListener("click", () => {
              scrollToIdx(getWrappedIndex(getCurrentIdx(), 1));
            });
          }

          tabs.forEach((tab, idx) => {
            tab.addEventListener("click", () => scrollToIdx(idx));

            tab.addEventListener("keydown", (e) => {
              if (e.key !== "ArrowRight" && e.key !== "ArrowLeft") return;

              e.preventDefault();
              const offset = e.key === "ArrowRight" ? 1 : -1;
              const nextIdx = getWrappedIndex(getCurrentIdx(), offset);

              scrollToIdx(nextIdx);

              if (tabs[nextIdx]) tabs[nextIdx].focus();
            });
          });

          // Auto rotation
          const startAutoRotation = () => {
            if (!isAutoRotationEnabled || autoRotationTimer != null) return;
            autoRotationTimer = setInterval(() => {
              const nextIdx = getWrappedIndex(getCurrentIdx(), 1);
              scrollToIdx(nextIdx);
            }, rotationIntervalMs);
          }

          const stopAutoRotation = () => {
            if (autoRotationTimer != null) {
              clearInterval(autoRotationTimer);
              autoRotationTimer = null;
            }
          }

          carousel.addEventListener('mouseenter', stopAutoRotation);
          carousel.addEventListener('mouseleave', startAutoRotation);

          carousel.addEventListener('focusin', stopAutoRotation);
          carousel.addEventListener('focusout', startAutoRotation);

          // Initialize
          syncActiveState();
          startAutoRotation();
        }
      }
    </script>
    """
  end
end
