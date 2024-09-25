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
    """
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :developing,
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - Roving tabindex
      - Move focus with arrow keys
      """,
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
    <div id={@id} class={@class} {@rest}>
      <div role="tablist" aria-label={@label} aria-labelledby={@labelledby}>
        <button
          :for={{panel, index} <- Enum.with_index(@panel, 1)}
          type="button"
          role="tab"
          id={"#{@id}-tab-#{index}"}
          aria-selected={to_string(index == 1)}
          aria-controls={"#{@id}-panel-#{index}"}
          tabindex={index != 1 && "-1"}
          phx-click={Doggo.show_tab(@id, index)}
        >
          <%= panel.label %>
        </button>
      </div>
      <div
        :for={{panel, index} <- Enum.with_index(@panel, 1)}
        id={"#{@id}-panel-#{index}"}
        role="tabpanel"
        aria-labelledby={"#{@id}-tab-#{index}"}
        hidden={index != 1}
      >
        <%= render_slot(panel) %>
      </div>
    </div>
    """
  end
end
