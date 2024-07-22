defmodule Doggo.Storybook.PageHeader do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: attributes(),
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: Map.merge(%{name => value}, attributes()),
      slots: slots()
    }
  end

  defp attributes do
    %{
      title: "Puppy Profiles",
      subtitle: "Share Your Pup's Story"
    }
  end

  defp slots do
    [
      """
      <:action>
        <Doggo.button_link
          patch="/puppies/new"
        >Add New Profile</Doggo.button_link>
      </:action>
      """
    ]
  end
end
