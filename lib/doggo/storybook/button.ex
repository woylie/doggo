defmodule Doggo.Storybook.Button do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        slots: ["click me"]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          disabled: true
        },
        slots: ["click me"]
      },
      %Variation{
        id: :busy,
        attributes: %{
          "aria-busy": true,
          "aria-label": "Saving..."
        },
        slots: ["click me"]
      }
    ]
  end

  def modifier_variation_base(_id, _name, value, _opts) do
    %{
      slots: [to_string(value || "nil")]
    }
  end
end
