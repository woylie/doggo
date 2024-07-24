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
    <.icon name="arrow-left" label="Go back" text_position={:right} />
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
      modifiers: [],
      extra: [
        text_position_after_class: "has-text-after",
        text_position_before_class: "has-text-before",
        text_position_hidden_class: nil,
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

      attr :text, :string,
        default: nil,
        doc: """
        Text that describes the icon.
        """

      attr :text_position, :string,
        default: "hidden",
        values: ["before", "after", "hidden"],
        doc: """
        Position of the text relative to the icon. If set to `"hidden"`, the
        `text` is visually hidden, but still accessible to screen readers.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(_opts, extra) do
    text_position_after_class =
      Keyword.fetch!(extra, :text_position_after_class)

    text_position_before_class =
      Keyword.fetch!(extra, :text_position_before_class)

    text_position_hidden_class =
      Keyword.fetch!(extra, :text_position_hidden_class)

    visually_hidden_class = Keyword.fetch!(extra, :visually_hidden_class)

    quote do
      text_position_class =
        case var!(assigns).text_position do
          "after" -> unquote(text_position_after_class)
          "before" -> unquote(text_position_before_class)
          "hidden" -> unquote(text_position_hidden_class)
        end

      text_class =
        if var!(assigns).text_position == "hidden",
          do: unquote(visually_hidden_class),
          else: nil

      var!(assigns) =
        assigns
        |> var!()
        |> Map.update!(:class, &(&1 ++ [text_position_class]))
        |> assign(:text_class, text_class)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <span class={@class} {@rest}>
      <svg aria-hidden="true"><use href={"#{@sprite_url}##{@name}"} /></svg>
      <span :if={@text} class={@text_class}>
        <%= @text %>
      </span>
    </span>
    """
  end
end
