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
    - `:sprite_url` - URL of the icon sprite. An expression such as
      `~p"/images/icons.svg"` is evaluated at render time, so a digested static
      path works.
    """
  end

  @impl true
  def usage do
    """
    Render an icon with a visually hidden label:

    ```heex
    <.icon_sprite name="arrow-left" label="Go back" />
    ```

    To display the label visibly:

    ```heex
    <.icon_sprite name="arrow-left" label="Go back" label_position="after" />
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
      ],
      render_options: [sprite_url: :string]
    ]
  end

  @impl true
  def nested_classes(base_class) do
    ["#{base_class}-label"]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :name, :string,
        required: true,
        doc: "Icon name as used in the sprite."

      attr :label, :string,
        default: nil,
        doc: """
        Text that describes the icon.
        """

      attr :label_position, :string,
        default: "hidden",
        values: ["before", "after", "hidden"],
        doc: """
        Position of the label relative to the icon. If set to `"hidden"`, the
        `label` is visually hidden, but still accessible to screen readers.

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
        Doggo.ensure_optional_name!(var!(assigns).label, unquote(name), "label")
      end

      ~H"""
      <span
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        data-label-position={@label_position}
        {@data_attrs}
        {@rest}
      >
        <svg aria-hidden="true"><use href={"#{Doggo.build(:sprite_url)}##{@name}"} /></svg>
        <span
          :if={@label}
          class={Doggo.build(:base_class, "-label")}
          data-visually-hidden={@label_position == "hidden"}
        >
          {@label}
        </span>
      </span>
      """
    end
  end
end
