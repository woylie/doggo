defmodule Doggo.Storybook.Breadcrumb do
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

  def modifier_variation_base(_id, _name, _value) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      ~s(<:item patch="/categories">Categories</:item>),
      ~s(<:item patch="/categories/1">Reviews</:item>),
      ~s(<:item patch="/categories/1/articles/1">The Movie</:item>)
    ]
  end
end
