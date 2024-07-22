defmodule Doggo.Storybook.AppBar do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          title: "Page title"
        },
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, value, opts) do
    %{
      attributes: %{title: value},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    [
      """
      <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
        #{icon(:menu, dependent_components)}
      </:navigation>
      """,
      """
      <:action label="Search" on_click={JS.push("search")}>
        #{icon(:search, dependent_components)}
      </:action>
      """,
      """
      <:action label="Like" on_click={JS.push("like")}>
        #{icon(:like, dependent_components)}
      </:action>
      """
    ]
  end
end
