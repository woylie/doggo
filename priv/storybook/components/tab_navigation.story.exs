defmodule Storybook.Components.TabNavigation do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.tab_navigation/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          current_value: :owners
        },
        slots: [
          ~s(<:item patch="/owners" value={:owners}>Owners</:item>),
          ~s(<:item patch="/pets" value={:pets}>Pets</:item>),
          ~s(<:item patch="/appointments" value={:appointments}>Appointments</:item>)
        ]
      }
    ]
  end
end
