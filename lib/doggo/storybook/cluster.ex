defmodule Doggo.Storybook.Cluster do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value},
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <div>One</div>
      <div>Two</div>
      <div>Three</div>
      """
    ]
  end
end
