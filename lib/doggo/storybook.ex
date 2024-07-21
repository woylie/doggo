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

  defmacro __using__(opts \\ []) do
    opts = Keyword.validate!(opts, [:module, :name])
    module = opts |> Keyword.fetch!(:module) |> Macro.expand(__ENV__)
    name = Keyword.fetch!(opts, :name)

    info = Map.fetch!(module.__dog_components__(), name)
    component = Keyword.fetch!(info, :component)
    modifiers = Keyword.fetch!(info, :modifiers)

    storybook_module = storybook_module(component)
    function = Function.capture(module, name, 1)

    quote do
      def function, do: unquote(function)

      def variations,
        do: unquote(storybook_module).variations(unquote(modifiers))
    end
  end

  defp storybook_module(component) when is_atom(component) do
    component_module = component |> Atom.to_string() |> String.capitalize()
    Module.safe_concat([Doggo.Storybook, component_module])
  end
end
