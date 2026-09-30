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
  def builder_doc do
    """
    - `:sprite_url` - URL of the icon sprite.
    """
  end

  @impl true
  def usage do
    """
    Render an icon with visually hidden text:

    ```heex
    <.icon name="arrow-left" text="Go back" />
    ```

    To display the text visibly:

    ```heex
    <.icon name="arrow-left" text="Go back" text_position={:right} />
    ```
    """
  end

  @impl true
  def css_path do
    "components/icon.css"
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :refining,
      base_class: "icon",
      modifiers: [],
      extra: [
        sprite_url: "/assets/icons/sprite.svg"
      ]
    ]
  end

  @impl true
  def nested_classes(base_class) do
    ["#{base_class}-text"]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :name, :string,
        required: true,
        doc: "Icon name as used in the sprite."

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

        This requires a CSS rule for the `data-visually-hidden` attribute. See
        [Visually hidden text](readme.html#visually-hidden-text).
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def template(opts) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      Doggo.diagnostic do
        Doggo.ensure_optional_name!(var!(assigns).text, unquote(name), "text")
      end

      ~H"""
      <span
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        data-text-position={@text_position}
        {@data_attrs}
        {@rest}
      >
        <svg aria-hidden="true"><use href={"#{Doggo.build(:sprite_url)}##{@name}"} /></svg>
        <span
          :if={@text}
          class={Doggo.build(:base_class, "-text")}
          data-visually-hidden={@text_position == "hidden"}
        >
          {@text}
        </span>
      </span>
      """
    end
  end
end
