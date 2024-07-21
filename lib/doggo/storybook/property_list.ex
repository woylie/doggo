defmodule Doggo.Storybook.PropertyList do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value},
      slots: slots()
    }
  end

  defp slots do
    [
      ~s(<:prop label="Name">George</:prop>),
      ~s(<:prop label="Age">42</:prop>)
    ]
  end
end
