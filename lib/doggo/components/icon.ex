defmodule Doggo.Components.Icon do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a customizable icon using a slot for SVG content.

    This component does not bind you to a specific set of icons. Instead, it
    provides a slot for inserting SVG content from any icon library you choose.
    """
  end

  @impl true
  def usage do
    """
    Render an icon with text as `aria-label` using the `heroicons` library:

    ```heex
    <.icon label="report bug"><Heroicons.bug_ant /></.icon>
    ```

    To display the text visibly:

    ```heex
    <.icon label="report bug" label_placement={:right}>
      <Heroicons.bug_ant />
    </.icon>
    ```

    > #### aria-hidden {: .info}
    >
    > Not all icon libraries set the `aria-hidden` attribute by default. Always
    > make sure that it is set on the `<svg>` element that the library renders.
    """
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [
        size: [
          values: ["small", "normal", "medium", "large"],
          default: "normal"
        ]
      ],
      extra: [
        visually_hidden_class: "is-visually-hidden"
      ]
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      slot :inner_block, doc: "Slot for the SVG element.", required: true

      attr :label, :string,
        default: nil,
        doc: """
        Text that describes the icon. If `label_placement` is set to `:hidden`,
        this text is set as `aria-label` attribute.
        """

      attr :label_placement, :atom,
        default: :hidden,
        values: [:left, :right, :hidden],
        doc: """
        Position of the label relative to the icon. If set to `:hidden`, the
        `label` text is used as `aria-label` attribute.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(_opts, extra) do
    visually_hidden_class = Keyword.fetch!(extra, :visually_hidden_class)

    quote do
      var!(assigns) =
        assigns
        |> var!()
        |> Map.update!(
          :class,
          &(&1 ++
              [Doggo.label_placement_class(var!(assigns).label_placement)])
        )
        |> assign(:visually_hidden_class, unquote(visually_hidden_class))
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <span class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
      <span
        :if={@label}
        class={@label_placement == :hidden && @visually_hidden_class}
      >
        <%= @label %>
      </span>
    </span>
    """
  end
end
