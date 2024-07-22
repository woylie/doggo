defmodule Doggo.Storybook.TabNavigation do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
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

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{current_value: :owners},
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
