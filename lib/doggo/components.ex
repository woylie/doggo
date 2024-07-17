defmodule Doggo.Components do
  @moduledoc """
  This module defines macros that generate customized components.

  ## Usage

      defmodule MyAppWeb.CoreComponents do
        use Phoenix.Component
        import Doggo.Components

        action_bar()
        badge()
      end

  ## Common Options

  All component macros support the following options:

  - `name` - The name of the function of the generated component. Defaults to
    the macro name.
  - `base_class` - The base class used on the root element of the component. If
    not set, a default base class is used.
  - `modifiers` - A keyword list of modifier attributes. For each item, an
    attribute with the type `:string` is added. The options will be passed to
    `Phoenix.Component.attr/3`. Most components define a set of default
    modifiers.
  - `class_name_fun` - A 1-arity function that takes a modifier attribute value
    and returns a CSS class name. Defaults to `Doggo.modifier_class_name/1`.
  """

  use Phoenix.Component

  @sizes ["small", "normal", "medium", "large"]
  @variants ["primary", "secondary", "info", "success", "warning", "danger"]

  @action_bar_doc """
  The action bar offers users quick access to primary actions within the
  application.

  It is typically positioned to float above other content.

  > #### In Development {: .warning}
  >
  > The necessary JavaScript for making this component fully functional and
  > accessible will be added in a future version.
  >
  > **Missing features**
  >
  > - Roving tabindex
  > - Move focus with arrow keys
  """

  @action_bar_usage """
  ## Usage

  ```heex
  <Doggo.action_bar>
    <:item label="Edit" on_click={JS.push("edit")}>
      <Doggo.icon size={:small}><Lucideicons.pencil aria-hidden /></Doggo.icon>
    </:item>
    <:item label="Move" on_click={JS.push("move")}>
      <Doggo.icon size={:small}><Lucideicons.move aria-hidden /></Doggo.icon>
    </:item>
    <:item label="Archive" on_click={JS.push("archive")}>
      <Doggo.icon size={:small}><Lucideicons.archive aria-hidden /></Doggo.icon>
    </:item>
  </Doggo.action_bar>
  ```
  """

  @doc """
  #{@action_bar_doc}

  ## Generate Component

  With default options:

      action_bar()

  Overriding the defaults:

      action_bar(
        base_class: "action-bar",
        modifiers: [
          size: [values: #{inspect(@sizes)}, default: "normal"]
        ]
      )

  #{@action_bar_usage}
  """

  @doc type: :component
  @doc since: "0.6.0"

  defmacro action_bar(opts \\ []) do
    opts =
      Keyword.validate!(opts,
        name: :action_bar,
        base_class: "action-bar",
        modifiers: [],
        class_name_fun: &Doggo.modifier_class_name/1
      )

    name = Keyword.fetch!(opts, :name)
    base_class = Keyword.fetch!(opts, :base_class)
    modifiers = Keyword.fetch!(opts, :modifiers)
    modifier_names = Keyword.keys(modifiers)
    class_name_fun = Keyword.fetch!(opts, :class_name_fun)

    quote do
      @doc """
      #{unquote(@action_bar_doc)}

      #{unquote(@action_bar_usage)}
      """

      for {name, modifier_opts} <- unquote(modifiers) do
        attr name, :string, modifier_opts
      end

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :label, :string, required: true
        attr :on_click, JS, required: true
      end

      def unquote(name)(var!(assigns)) do
        var!(assigns) =
          assign(var!(assigns),
            base_class: unquote(base_class),
            modifier_classes:
              Doggo.Components.modifier_classes(
                unquote(modifier_names),
                unquote(class_name_fun),
                var!(assigns)
              )
          )

        ~H"""
        <div role="toolbar" class={[@base_class | @modifier_classes]} {@rest}>
          <button :for={item <- @item} phx-click={item.on_click} title={item.label}>
            <%= render_slot(item) %>
          </button>
        </div>
        """
      end
    end
  end

  @badge_doc """
  Generates a badge component, typically used for drawing attention to elements
  like notification counts.
  """

  @badge_usage """
  ## Usage

  ```heex
  <Doggo.badge>8</Doggo.badge>
  ```
  """

  @doc """
  #{@badge_doc}

  ## Generate Component

  With default options:

      badge()

  Overriding the defaults:

      badge(
        base_class: "badge",
        modifiers: [
          size: [values: #{inspect(@sizes)}, default: "normal"],
          variant: [values: #{inspect(@variants)}, default: nil]
        ]
      )

  #{@badge_usage}
  """

  @doc type: :component
  @doc since: "0.6.0"

  defmacro badge(opts \\ []) do
    opts =
      Keyword.validate!(opts,
        name: :badge,
        base_class: "badge",
        modifiers: [
          size: [values: @sizes, default: "normal"],
          variant: [values: [nil | @variants], default: nil]
        ],
        class_name_fun: &Doggo.modifier_class_name/1
      )

    name = Keyword.fetch!(opts, :name)
    base_class = Keyword.fetch!(opts, :base_class)
    modifiers = Keyword.fetch!(opts, :modifiers)
    modifier_names = Keyword.keys(modifiers)
    class_name_fun = Keyword.fetch!(opts, :class_name_fun)

    quote do
      @doc """
      #{unquote(@badge_doc)}

      #{unquote(@badge_usage)}
      """

      for {name, modifier_opts} <- unquote(modifiers) do
        attr name, :string, modifier_opts
      end

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block, required: true

      def unquote(name)(var!(assigns)) do
        var!(assigns) =
          assign(var!(assigns),
            base_class: unquote(base_class),
            modifier_classes:
              Doggo.Components.modifier_classes(
                unquote(modifier_names),
                unquote(class_name_fun),
                var!(assigns)
              )
          )

        ~H"""
        <span class={[@base_class | @modifier_classes]} {@rest}>
          <%= render_slot(@inner_block) %>
        </span>
        """
      end
    end
  end

  @doc false
  def modifier_classes(modifier_names, class_name_fun, assigns) do
    for name <- modifier_names do
      case assigns do
        %{^name => value} when is_binary(value) -> class_name_fun.(value)
        _ -> nil
      end
    end
  end
end
