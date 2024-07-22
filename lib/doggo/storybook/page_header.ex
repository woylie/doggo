defmodule Doggo.Storybook.PageHeader do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:button_link]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: attributes(),
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: attributes(),
      slots: slots(opts)
    }
  end

  defp attributes do
    %{
      title: "Puppy Profiles",
      subtitle: "Share Your Pup's Story"
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    [
      """
      <:action>
        #{patch_link("/puppies/new", "Add New Profile", dependent_components)}
      </:action>
      """
    ]
  end
end
