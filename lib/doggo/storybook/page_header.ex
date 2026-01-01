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
        slots: slots(:default, opts)
      },
      %Variation{
        id: :with_navigation,
        attributes: attributes(),
        slots: slots(:with_navigation, opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: attributes(),
      slots: slots(:default, opts)
    }
  end

  defp attributes do
    %{
      title: "Puppy Profiles",
      subtitle: "Share Your Pup's Story"
    }
  end

  defp slots(:default, opts) do
    dependent_components = opts[:dependent_components]

    [
      """
      <:action>
        #{patch_link("/puppies/new", "Add New Profile", dependent_components)}
      </:action>
      """
    ]
  end

  defp slots(:with_navigation, opts) do
    dependent_components = opts[:dependent_components]

    [
      """
      <:navigation navigate="/puppies">
        Back to puppy list
      </:navigation>
      <:action>
        #{patch_link("/puppies/1/edit", "Edit Profile", dependent_components)}
      </:action>
      """
    ]
  end
end
