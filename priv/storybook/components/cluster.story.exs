defmodule Storybook.Components.Cluster do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.cluster/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          """
          <div>Hello!</div>
          <div>How are you?</div>
          <div>Goodbye!</div>
          """
        ]
      }
    ]
  end
end
