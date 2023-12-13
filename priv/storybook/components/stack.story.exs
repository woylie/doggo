defmodule Storybook.Components.Stack do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.stack/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          """
          <div>Hello!</div>
          <div>Bye!</div>
          """
        ]
      },
      %Variation{
        id: :recursive,
        attributes: %{recursive: true},
        slots: [
          """
          <div>
            <div>Hello!</div>
            <div>Are you good boy?</div>
          </div>
          <div>Bye!</div>
          """
        ]
      }
    ]
  end
end
