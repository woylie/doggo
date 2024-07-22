defmodule Doggo.Storybook.Alert do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: slots()
      },
      %Variation{
        id: :title,
        attributes: %{title: "This is the title."},
        slots: slots()
      },
      %Variation{
        id: :close_button,
        attributes: %{
          on_close: {:eval, ~s|JS.hide(to: "#alert-single-close-button")|}
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, name, value, _opts) do
    %{
      slots: ["This is an alert with #{name}: #{value}."]
    }
  end

  defp slots do
    ["This is an alert."]
  end
end
