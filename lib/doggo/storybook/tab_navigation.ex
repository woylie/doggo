defmodule Doggo.Storybook.TabNavigation do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          current_value: :owners
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, current_value: :owners},
      slots: slots()
    }
  end

  defp slots do
    [
      ~s(<:item patch="/owners" value={:owners}>Owners</:item>),
      ~s(<:item patch="/pets" value={:pets}>Pets</:item>),
      ~s(<:item patch="/appointments" value={:appointments}>Appointments</:item>)
    ]
  end
end
