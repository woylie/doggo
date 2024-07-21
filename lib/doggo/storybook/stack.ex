defmodule Doggo.Storybook.Stack do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        slots: slots()
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
          <div>How are you?</div>
          <div>Bye!</div>
          """
        ]
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value},
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <div>Hello!</div>
      <div>How are you?</div>
      <div>Bye!</div>
      """
    ]
  end
end
