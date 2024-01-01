defmodule Storybook.Components.Frame do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.frame/1

  def variations do
    [
      %VariationGroup{
        id: :ratios,
        variations:
          for {n, d} = ratio <- Doggo.ratios() do
            %Variation{
              id: :"#{n}_to_#{d}",
              attributes: %{ratio: ratio},
              slots: [
                """
                <img
                  src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
                  alt="A dog wearing a colorful poncho walks down a fashion show runway."
                />
                """
              ]
            }
          end
      },
      %Variation{
        id: :circle,
        attributes: %{circle: true},
        slots: [
          """
          <img
            src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
            alt="A dog wearing a colorful poncho walks down a fashion show runway."
          />
          """
        ]
      }
    ]
  end
end
