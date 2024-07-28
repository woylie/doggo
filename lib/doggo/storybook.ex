defmodule Doggo.Storybook do
  @moduledoc """
  Generates [Phoenix Storybook](https://hex.pm/packages/phoenix_storybook)
  stories for the Doggo components.

  ## Usage

  In your story module, use `Doggo.Storybook` and pass the name of the module
  in which you call the `Doggo.Components` macros and the name of the component
  (not the macro name).

      defmodule Storybook.Components.Accordion do
        use PhoenixStorybook.Story, :component
        use Doggo.Storybook, module: MyAppWeb.CoreComponents, name: :accordion
      end

  You can automatically generate story modules for all configured components
  with `mix dog.gen.stories`.
  """

  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  defmacro __using__(opts \\ []) do
    opts = Keyword.validate!(opts, [:module, :name])
    module = opts |> Keyword.fetch!(:module) |> Macro.expand(__ENV__)
    name = Keyword.fetch!(opts, :name)

    components = module.__dog_components__()
    info = Map.fetch!(components, name)
    component = Keyword.fetch!(info, :component)
    modifiers = Keyword.fetch!(info, :modifiers)

    storybook_module = storybook_module(component)
    {:module, _} = Code.ensure_loaded(module)
    {:module, _} = Code.ensure_loaded(storybook_module)
    function = Function.capture(module, name, 1)

    dependent_components =
      find_dependent_components(components, storybook_module)

    imports =
      if dependent_components != [] do
        [
          {module,
           Enum.map(dependent_components, fn {_component, name} ->
             {name, 1}
           end)}
        ]
      end

    story_opts = [dependent_components: dependent_components, name: name]

    quote do
      if unquote(imports) do
        def imports, do: unquote(imports)
      end

      def function, do: unquote(function)

      if unquote(function_exported?(storybook_module, :container, 0)) do
        def container, do: unquote(storybook_module).container()
      end

      if unquote(function_exported?(storybook_module, :layout, 0)) do
        def layout, do: unquote(storybook_module).layout()
      end

      if unquote(function_exported?(storybook_module, :template, 0)) do
        def template,
          do: unquote(storybook_module).template()
      end

      if unquote(function_exported?(storybook_module, :template, 1)) do
        def template,
          do:
            unquote(storybook_module).template(
              unquote(Macro.escape(story_opts))
            )
      end

      def variations do
        unquote(storybook_module).variations(unquote(Macro.escape(story_opts))) ++
          Doggo.Storybook.modifier_groups(
            unquote(modifiers),
            unquote(storybook_module),
            unquote(Macro.escape(story_opts))
          )
      end
    end
  end

  defp storybook_module(component) when is_atom(component) do
    component_module = component |> Atom.to_string() |> Macro.camelize()
    Module.concat([Doggo.Storybook, component_module])
  end

  defp find_dependent_components(components, storybook_module) do
    if function_exported?(storybook_module, :dependent_components, 0) do
      storybook_module.dependent_components()
      |> Enum.map(fn component ->
        find_component_name(components, component)
      end)
      |> Enum.reject(&is_nil/1)
      |> Map.new()
    else
      []
    end
  end

  defp find_component_name(components, component) do
    Enum.find_value(components, fn
      {name, info} ->
        if Keyword.get(info, :component) == component, do: {component, name}
    end)
  end

  @doc false
  def story_template(module, name) do
    loaded =
      module.__dog_components__()
      |> Map.fetch!(name)
      |> Keyword.fetch!(:component)
      |> storybook_module()
      |> Code.ensure_loaded()

    case loaded do
      {:module, _} ->
        module = module |> to_string() |> String.trim_leading("Elixir.")
        name_module = name |> to_string() |> Macro.camelize()

        """
        defmodule Storybook.Components.#{name_module} do
          use PhoenixStorybook.Story, :component
          use Doggo.Storybook, module: #{module}, name: :#{name}
        end
        """

      _ ->
        nil
    end
  end

  @doc false
  def modifier_groups(modifiers, storybook_module, opts) do
    Enum.map(modifiers, &modifier_group(&1, storybook_module, opts))
  end

  @doc false
  def modifier_group({name, modifier_opts}, storybook_module, opts) do
    {:module, _} = Code.ensure_loaded(storybook_module)

    template =
      if function_exported?(
           storybook_module,
           :modifier_variation_group_template,
           2
         ) do
        storybook_module.modifier_variation_group_template(name, opts)
      end

    %VariationGroup{
      id: name,
      variations:
        modifier_variations(name, modifier_opts, storybook_module, opts),
      template: template
    }
  end

  @doc false
  def modifier_variations(name, modifier_opts, storybook_module, opts) do
    values = Keyword.fetch!(modifier_opts, :values)
    Enum.map(values, &modifier_variation_base(name, &1, storybook_module, opts))
  end

  @doc false
  def modifier_variation_base(name, value, storybook_module, opts) do
    variation_id = String.to_atom(~s(dog_mod_var_#{name}_#{value || "unset"}))
    component_id = String.to_atom(~s(dog-mod-com-#{name}-#{value || "unset"}))

    attrs =
      component_id
      |> storybook_module.modifier_variation_base(name, value, opts)
      |> Map.put(:id, variation_id)
      |> Map.update(:attributes, %{name => value}, &Map.put(&1, name, value))

    struct!(Variation, attrs)
  end
end
