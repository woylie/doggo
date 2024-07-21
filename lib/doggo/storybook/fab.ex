defmodule Doggo.Storybook.Fab do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Add item"},
        slots: slots()
      },
      %Variation{
        id: :disabled,
        attributes: %{label: "Add item", disabled: true},
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, label: "Add item"},
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="lucide lucide-plus"
      >
        <path d="M5 12h14"/>
        <path d="M12 5v14"/>
      </svg>
      """
    ]
  end
end
