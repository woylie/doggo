defmodule Doggo.Storybook.ToggleButton do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          on_click: %Phoenix.LiveView.JS{},
          pressed: false
        },
        slots: ["click me"]
      },
      %Variation{
        id: :pressed,
        attributes: %{
          on_click: %Phoenix.LiveView.JS{},
          pressed: true
        },
        slots: ["click me"]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          on_click: %Phoenix.LiveView.JS{},
          disabled: true
        },
        slots: ["click me"]
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{
        name => value,
        :on_click => %Phoenix.LiveView.JS{},
        :pressed => false
      },
      slots: ["Mute"]
    }
  end
end
