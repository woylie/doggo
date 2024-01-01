defmodule Storybook.Components.Skeleton do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.skeleton/1

  def variations do
    [
      %VariationGroup{
        id: :types,
        variations:
          for type <- Doggo.skeleton_types() do
            %Variation{
              id: type,
              attributes: %{type: type}
            }
          end
      }
    ]
  end
end
