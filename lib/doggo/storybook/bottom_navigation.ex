defmodule Doggo.Storybook.BottomNavigation do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          current_value: Profile
        },
        slots: slots(opts)
      },
      %Variation{
        id: :hidden_labels,
        attributes: %{
          current_value: Profile,
          hide_labels: true
        },
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{current_value: Profile},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    [
      """
      <:item label="Profile" navigate="/profile" value={Profile}>
        #{icon(:user, dependent_components)}
      </:item>
      """,
      """
      <:item label="Appointments" navigate="/appointments" value={Appointments}>
        #{icon(:calendar, dependent_components)}
      </:item>
      """,
      """
      <:item label="Messages" navigate="/messages" value={Messages}>
        #{icon(:mails, dependent_components)}
      </:item>
      """
    ]
  end
end
