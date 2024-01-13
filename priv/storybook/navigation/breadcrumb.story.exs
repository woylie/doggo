defmodule Storybook.Components.Breadcrumb do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.breadcrumb/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          ~s(<:item patch="/categories">Categories</:item>),
          ~s(<:item patch="/categories/1">Reviews</:item>),
          ~s(<:item patch="/categories/1/articles/1">The Movie</:item>)
        ]
      }
    ]
  end
end
