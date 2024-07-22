defmodule Doggo.Storybook.Steps do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :without_links,
        attributes: %{
          current_step: 1
        },
        slots: steps_without_links()
      },
      %Variation{
        id: :non_linear,
        attributes: %{
          current_step: 1
        },
        slots: steps_with_links()
      },
      %Variation{
        id: :linear,
        attributes: %{
          current_step: 1,
          linear: true
        },
        slots: steps_with_links()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value) do
    %{
      attributes: %{current_step: 1},
      slots: steps_with_links()
    }
  end

  defp steps_without_links do
    [
      """
      <:step>Profile</:step>
      """,
      """
      <:step>Delivery</:step>
      """,
      """
      <:step>Confirmation</:step>
      """
    ]
  end

  defp steps_with_links do
    [
      """
      <:step on_click={Phoenix.LiveView.JS.push("go-to-step", value: %{step: "profile"})}>
        Profile
      </:step>
      """,
      """
      <:step on_click={Phoenix.LiveView.JS.push("go-to-step", value: %{step: "delivery"})}>
        Delivery
      </:step>
      """,
      """
      <:step on_click={Phoenix.LiveView.JS.push("go-to-step", value: %{step: "confirmation"})}>
        Confirmation
      </:step>
      """
    ]
  end
end
