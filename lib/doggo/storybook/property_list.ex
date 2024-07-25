defmodule Doggo.Storybook.PropertyList do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def container, do: {:div, class: "container"}
  def layout, do: :one_column

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      ~s|<:prop label="Name">Apollo</:prop>|,
      ~s|<:prop label="Age">5</:prop>|,
      ~s|<:prop label="Breed">Golden Retriever</:prop>|,
      ~s|<:prop label="Favorite Toy">Frisbee</:prop>|,
      ~s|<:prop label="Owner">Katrin Dinkelschrot</:prop>|,
      ~s|<:prop label="Health Conditions and Dietary Requirements">Apollo has a sensitive stomach and requires a special diet, including grain-free food and regular vet check-ups.</:prop>|
    ]
  end
end
