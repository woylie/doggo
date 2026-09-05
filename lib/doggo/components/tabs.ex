defmodule Doggo.Components.Tabs do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders tab panels.

    This component is meant for tabs that toggle content panels within the page.
    If you want to link to a different view or live action, use
    `tab_navigation/1` instead.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.tabs id="dog-breed-profiles" label="Dog Breed Profiles">
      <:panel label="Golden Retriever">
        <p>
          Friendly, intelligent, great with families. Origin: Scotland. Needs
          regular exercise.
        </p>
      </:panel>
      <:panel label="Siberian Husky">
        <p>
          Energetic, outgoing, distinctive appearance. Origin: Northeast Asia.
          Loves cold climates.
        </p>
      </:panel>
      <:panel label="Dachshund">
        <p>
          Playful, stubborn, small size. Origin: Germany. Enjoys sniffing games.
        </p>
      </:panel>
    </.tabs>
    ```

    This component defines a colocated Phoenix LiveView hook with the name
    `Doggo.Components.Tabs.Hook`.

    ```js
    import { hooks as doggoHooks } from "phoenix-colocated/doggo";

    const Hooks = {
      'Doggo.Components.Tabs.Hook': doggoHooks['Doggo.Components.Tabs.Hook']
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
    - `Left` and `Right` - previous or next tab, wrapping at the ends.
    - `Home` and `End` - first and last tab.
    - `Enter` or `Space` - select the focused tab.

    The tab list is a single tab stop. The arrow keys, `home` and `end` need
    the colocated hook.
    """
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :refining,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :label, :string,
        default: nil,
        doc: """
        A accessibility label for the tabs. Set as `aria-label` attribute.

        You should ensure that either the `label` or the `labelledby` attribute is
        set.

        Do not repeat the word `tab list` or similar in the label, since it is
        already announced by screen readers.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels the tabs.

        Example:

        ```html
        <h3 id="my-tabs-label">Dogs</h3>
        <Doggo.tabs labelledby="my-tabs-label"></Doggo.tabs>
        ```

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :panel, required: true do
        attr :label, :string
      end
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    Doggo.ensure_label!(assigns, ".tabs", "Dog Facts")

    ~H"""
    <div id={@id} class={@class} {@data_attrs} {@rest} phx-hook=".Hook">
      <div role="tablist" aria-label={@label} aria-labelledby={@labelledby}>
        <button
          :for={{panel, index} <- Enum.with_index(@panel, 1)}
          type="button"
          role="tab"
          id={"#{@id}-tab-#{index}"}
          aria-selected={to_string(index == 1)}
          aria-controls={"#{@id}-panel-#{index}"}
          tabindex={if index == 1, do: "0", else: "-1"}
          phx-click={Doggo.show_tab(@id, index)}
        >
          {panel.label}
        </button>
      </div>
      <div
        :for={{panel, index} <- Enum.with_index(@panel, 1)}
        id={"#{@id}-panel-#{index}"}
        role="tabpanel"
        aria-labelledby={"#{@id}-tab-#{index}"}
        hidden={index != 1}
      >
        {render_slot(panel)}
      </div>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Hook">
      export default {
        mounted() {
          const tabs = this.el;

          const getTabs = () =>
            Array.from(
              tabs.querySelectorAll(':scope > [role="tablist"] > [role="tab"]')
            );

          const getPanels = () =>
            Array.from(tabs.querySelectorAll(':scope > [role="tabpanel"]'));

          let selectedIdx = 0;

          const select = (idx) => {
            selectedIdx = idx;

            getTabs().forEach((tab, i) => {
              const selected = i === idx;
              tab.setAttribute("aria-selected", selected ? "true" : "false");
              tab.setAttribute("tabindex", selected ? "0" : "-1");
            });

            getPanels().forEach((panel, i) => {
              if (i === idx) {
                panel.removeAttribute("hidden");
              } else {
                panel.setAttribute("hidden", "");
              }
            });
          };

          tabs.addEventListener("click", (e) => {
            const idx = getTabs().indexOf(e.target.closest('[role="tab"]'));

            if (idx >= 0) selectedIdx = idx;
          });

          tabs.addEventListener("keydown", (e) => {
            const currentIdx = getTabs().indexOf(e.target.closest('[role="tab"]'));

            if (currentIdx < 0) return;

            const total = getTabs().length;
            let nextIdx;

            if (e.key === "ArrowRight") {
              nextIdx = (currentIdx + 1) % total;
            } else if (e.key === "ArrowLeft") {
              nextIdx = (currentIdx - 1 + total) % total;
            } else if (e.key === "Home") {
              nextIdx = 0;
            } else if (e.key === "End") {
              nextIdx = total - 1;
            } else {
              return;
            }

            e.preventDefault();
            select(nextIdx);
            getTabs()[nextIdx].focus();
          });

          this.restoreSelection = () => {
            const total = getTabs().length;

            if (total > 0) select(Math.min(selectedIdx, total - 1));
          };
        },

        // Restore selected tab on patch.
        updated() {
          this.restoreSelection();
        }
      }
    </script>
    """
  end
end
