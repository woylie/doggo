defmodule Storybook.Components.Frame do
  use PhoenixStorybook.Story, :component

  @ratios [
    {1, 1},
    {3, 2},
    {2, 3},
    {4, 3},
    {3, 4},
    {5, 4},
    {4, 5},
    {16, 9},
    {9, 16}
  ]

  def function, do: &Doggo.frame/1

  def variations do
    [
      %VariationGroup{
        id: :ratios,
        variations:
          for {n, d} = ratio <- @ratios do
            %Variation{
              id: :"#{n}_to_#{d}",
              attributes: %{ratio: ratio},
              slots: [
                """
                <img
                  src="https://github.com/woylie/doggo/blob/main/dog_poncho.jpg?raw=true"
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
            src="https://github.com/woylie/doggo/blob/main/dog_poncho.jpg?raw=true"
            alt="A dog wearing a colorful poncho walks down a fashion show runway."
          />
          """
        ]
      }
    ]
  end
end
