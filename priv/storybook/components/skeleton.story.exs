defmodule Storybook.Components.Skeleton do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.skeleton/1

  def variations do
    [
      %VariationGroup{
        id: :types,
        variations:
          for type <- [
                :text_line,
                :text_block,
                :image,
                :circle,
                :rectangle,
                :square
              ] do
            %Variation{
              id: type,
              attributes: %{type: type}
            }
          end
      }
    ]
  end
end
