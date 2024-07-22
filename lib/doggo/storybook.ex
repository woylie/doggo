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
    function = Function.capture(module, name, 1)

    quote do
      def function, do: unquote(function)

      if unquote(function_exported?(storybook_module, :layout, 0)) do
        def layout, do: unquote(storybook_module).layout()
      end

      if unquote(function_exported?(storybook_module, :template, 0)) do
        def template, do: unquote(storybook_module).template()
      end

      def variations do
        unquote(storybook_module).variations() ++
          Doggo.Storybook.modifier_groups(
            unquote(modifiers),
            unquote(storybook_module)
          )
      end
    end
  end

  defp storybook_module(component) when is_atom(component) do
    component_module = component |> Atom.to_string() |> Macro.camelize()
    Module.safe_concat([Doggo.Storybook, component_module])
  end

  @doc false
  def story_template(module, name) do
    """
    defmodule Storybook.Components.Accordion do
      use PhoenixStorybook.Story, :component
      use Doggo.Storybook, module: #{module}, name: :#{name}
    end
    """
  end

  @doc false
  def modifier_groups(modifiers, storybook_module) do
    Enum.map(modifiers, &modifier_group(&1, storybook_module))
  end

  @doc false
  def modifier_group({name, modifier_opts}, storybook_module) do
    %VariationGroup{
      id: name,
      variations: modifier_variations(name, modifier_opts, storybook_module)
    }
  end

  @doc false
  def modifier_variations(name, modifier_opts, storybook_module) do
    values = Keyword.fetch!(modifier_opts, :values)
    Enum.map(values, &modifier_variation_base(name, &1, storybook_module))
  end

  @doc false
  def modifier_variation_base(name, value, storybook_module) do
    variation_id = String.to_atom(~s(dog_mod_var_#{name}_#{value || "unset"}))
    component_id = String.to_atom(~s(dog-mod-com-#{name}-#{value || "unset"}))

    attrs =
      component_id
      |> storybook_module.modifier_variation_base(name, value)
      |> Map.put(:id, variation_id)
      |> Map.update(:attributes, %{}, &Map.put(&1, name, value))

    struct!(Variation, attrs)
  end
end
