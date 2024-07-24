defmodule Doggo.Components.IconSprite do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders an icon using an SVG sprite.
    """
  end

  @impl true
  def usage do
    """
    Render an icon with text as `aria-label`:

    ```heex
    <.icon name="arrow-left" label="Go back" />
    ```

    To display the text visibly:

    ```heex
    <.icon name="arrow-left" label="Go back" label_placement={:right} />
    ```
    """
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :developing,
      base_class: "icon",
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
      attr :name, :string,
        required: true,
        doc: "Icon name as used in the sprite."

      attr :sprite_url, :string,
        default: "/assets/icons/sprite.svg",
        doc: "The URL of the SVG sprite."

      attr :label, :string,
        default: nil,
        doc: """
        Text that describes the icon. If `label_placement` is set to `:hidden`, this
        text is set as `aria-label` attribute.
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
      <svg aria-hidden="true"><use href={"#{@sprite_url}##{@name}"} /></svg>
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
