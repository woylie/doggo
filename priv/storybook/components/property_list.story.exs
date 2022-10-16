defmodule Storybook.Components.Icon do
  use PhxLiveStorybook.Story, :component

  def function, do: &Doggo.property_list/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
        ~s(<:prop label="Name">George</:prop>),
        ~s(<:prop label="Age"}>42</:prop>)
        ]
      }
    ]
  end
end
