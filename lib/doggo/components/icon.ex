defmodule Doggo.Components.Icon do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders an icon with optional text.

    The component does not make assumptions about the icon library. Instead, it
    allows you to reference functions from libraries or custom functions that
    render SVG icons.
    """
  end

  @impl true
  def builder_doc do
    """
    - `:icon_module` (required) - The module that defines the function
      component(s) for rendering the icon SVG elements.
    - `:icon_fun` - The name of a function component defined in the icon module
      that has a `name` attribute (string) renders the corresponding icon
      SVG element. If not set, the component will use the function component
      with the same name as the icon name and not set any attributes.
    - `:names` - Either a list of available icon names or a 0-arity function
      that returns the list. This is only used in the generated storybook.
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
    ## Configuration

    For icon libraries that define a separate function component for each
    individual icon such as `heroicons`, you need to set the `icon_module`
    option.

    ```elixir
    defmodule MyAppWeb.CoreComponents do
      use Doggo.Components
      use Phoenix.Component

      build_icon(icon_module: Heroicons)
    end
    ```

    The `name` attribute passed to the generated icon component needs to
    reference a function component in the configured module.

    ```heex
    <.icon name="bug_ant" />
    ```

    In this example, the icon component will use `Heroicons.bug_ant/1` to render
    the SVG icon in its inner markup.

    Names are internally normalized by replacing dashes with underscores.
    Therefore, both `name="bug_ant"` and `name="bug-ant"` will work.

    For icon libraries that expose a single function component, you can
    additionally set the `icon_fun` option.

    ```elixir
    build_icon(icon_module: MyIcons, icon_fun: :render)
    ```

    In that case, the generated icon component will pass the `name` attribute
    on to the referenced function component.

    ```heex
    <.icon name="circle-question" />
    ```

    In this example, the generated markup will be similar to:

    ```heex
    <span class="icon">
      <MyIcons.render name="circle-question" />
    </span>
    ```

    ## Text display

    Render an icon with visually hidden text:

    ```heex
    <.icon name="bug_ant" text="report bug" />
    ```

    To display the text visibly:

    ```heex
    <.icon name="bug_ant" text="report bug" text_position="after" />
    ```

    Or:

    ```heex
    <.icon name="bug_ant" text="report bug" text_position="before" />
    ```

    The `text_position` attribute values are chosen to work with both
    left-to-right and right-to-left languages. Refer to the CSS example for
    applying the position correctly.

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
        icon_module: nil,
        icon_fun: nil,
        names: [],
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
      attr :name, :string, required: true, doc: "The name of the icon."

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
    icon_module = Keyword.fetch!(extra, :icon_module)
    icon_fun = Keyword.fetch!(extra, :icon_fun)

    if is_nil(icon_module) do
      raise """
      missing icon_module option

      The icon component requires the `icon_module` option to be set.

      If the `icon_module` option is set without the `icon_fun` option, the
      module is expected to define function components that render the icons
      with the same name as the `name` attribute passed to the icon component.

      If the `icon_fun` option is set, the function referenced with
      `icon_module` and `icon_fun` must be a function component that accepts
      a `name` string attribute and renders the corresponding icon.
      """
    end

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
        |> assign(:icon_module, unquote(icon_module))
        |> assign(:icon_fun, unquote(icon_fun))
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <span class={@class} {@rest}>
      <Doggo.Components.Icon.dynamic_icon
        name={@name}
        module={@icon_module}
        fun={@icon_fun}
      />
      <span :if={@text} class={@text_class}>
        {@text}
      </span>
    </span>
    """
  end

  @doc false

  attr :name, :string, required: true
  attr :module, :atom
  attr :fun, :atom

  def dynamic_icon(%{module: module, fun: nil} = assigns)
      when is_atom(module) do
    {module, assigns} = Map.pop!(assigns, :module)
    {name, assigns} = Map.pop!(assigns, :name)
    name = String.replace(name, "-", "_")
    apply(module, String.to_existing_atom(name), [assigns])
  end

  def dynamic_icon(%{module: module, fun: fun} = assigns)
      when is_atom(module) and is_atom(fun) do
    {module, assigns} = Map.pop!(assigns, :module)
    {fun, assigns} = Map.pop!(assigns, :fun)
    apply(module, fun, [assigns])
  end
end
