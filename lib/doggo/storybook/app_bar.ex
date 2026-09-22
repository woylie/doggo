defmodule Doggo.Storybook.AppBar do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon]

  def layout, do: :one_column

  def template do
    """
    <div style="inline-size: 100%">
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{id: "dog-app-bar-1", title: "Page title"},
        slots: [navigation(opts), search(opts), like(opts)]
      },
      %Variation{
        id: :without_navigation,
        attributes: %{id: "dog-app-bar-2", title: "Page title"},
        slots: [search(opts), like(opts)]
      },
      %Variation{
        id: :without_actions,
        attributes: %{id: "dog-app-bar-3", title: "Page title"},
        slots: [navigation(opts)]
      },
      %Variation{
        id: :title_only,
        attributes: %{id: "dog-app-bar-4", title: "Page title"},
        slots: []
      },
      %Variation{
        id: :without_title,
        attributes: %{id: "dog-app-bar-5"},
        slots: [navigation(opts), search(opts), like(opts)]
      }
    ]
  end

  def modifier_variation_base(id, _name, value, opts) do
    %{
      attributes: %{id: id, title: value},
      slots: [navigation(opts), search(opts), like(opts)]
    }
  end

  defp navigation(opts) do
    """
    <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
      #{icon(:menu, opts[:dependent_components])}
    </:navigation>
    """
  end

  defp search(opts) do
    """
    <:action label="Search" on_click={JS.push("search")}>
      #{icon(:search, opts[:dependent_components])}
    </:action>
    """
  end

  defp like(opts) do
    """
    <:action label="Like" on_click={JS.push("like")}>
      #{icon(:like, opts[:dependent_components])}
    </:action>
    """
  end
end
