defmodule Doggo.Storybook.ActionBar do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_, _, _, opts) do
    %{
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    [
      """
      <:item label="Edit" on_click={JS.push("edit")}>
        #{icon(:edit, dependent_components)}
      </:item>
      """,
      """
      <:item label="Move" on_click={JS.push("move")}>
        #{icon(:move, dependent_components)}
      </:item>
      """,
      """
      <:item label="Archive" on_click={JS.push("archive")}>
        #{icon(:archive, dependent_components)}
      </:item>
      """
    ]
  end
end
