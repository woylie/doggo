defmodule Doggo.Storybook.ButtonLink do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
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
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value},
      slots: [to_string(value || "nil")]
    }
  end
end
