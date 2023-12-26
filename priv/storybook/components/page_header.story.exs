defmodule Storybook.Components.PageHeader do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.page_header/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          title: "Puppy Profiles",
          subtitle: "Share Your Pup's Story"
        },
        slots: [
          """
          <:action>
            <Doggo.button_link
              patch="/puppies/new"
            >Add New Profile</Doggo.button_link>
          </:action>
          """
        ]
      }
    ]
  end
end
