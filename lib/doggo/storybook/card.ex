defmodule Doggo.Storybook.Card do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def layout, do: :one_column

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:image>
        <img
          src="https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true"
          alt="A gray-muzzled dog in a camouflage coat and harness."
        />
      </:image>
      """,
      """
      <:body>
        The next dog fashion show is coming up quickly. Here's what you need
        to look out for.
      </:body>
      """,
      """
      <:header><h2>Dog Fashion Show</h2></:header>
      """,
      """
      <:footer>
        <span>2023-11-15 12:24</span>
        <span>Events</span>
      </:footer>
      """
    ]
  end
end
