defmodule Storybook.Components.FlashGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.flash_group/1

  def variations do
    [
      %Variation{
        id: :info,
        attributes: %{
          flash: %{"info" => "This was great!"}
        }
      },
      %Variation{
        id: :error,
        attributes: %{
          flash: %{"error" => "This was weird!"}
        }
      }
    ]
  end
end
