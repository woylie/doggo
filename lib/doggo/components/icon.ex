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
  def builder_doc do
    """
    - `:text_position_after_class` - This class is added to the root element if
      `:text_position` is set to `"after"`.
    - `:text_position_before_class` - This class is added to the root element if
      `:text_position` is set to `"before"`.
    - `:text_position_hidden_class` - This class is added to the root element
      if `:text_position` is set to `"hidden"`.
    - `:visually_hidden_class` - This class is added to the `<span>` containing
      the text if `:text_position` is set to `"hidden"`.
    """
  end

  @impl true
  def usage do
    """
    Render an icon with visually hidden text using the `heroicons` library:

    ```heex
    <.icon text="report bug"><Heroicons.bug_ant /></.icon>
    ```

    To display the text visibly:

    ```heex
    <.icon text="report bug" text_position="after">
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
  def css_path do
    "components/_icon.scss"
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :refining,
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
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      slot :inner_block, doc: "Slot for the SVG element.", required: true

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
      {render_slot(@inner_block)}
      <span :if={@text} class={@text_class}>
        {@text}
      </span>
    </span>
    """
  end
end
