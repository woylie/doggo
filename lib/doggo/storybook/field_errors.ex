defmodule Doggo.Storybook.FieldErrors do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:input]

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          for: "user_name",
          errors: errors()
        }
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        for: "user_name",
        errors: errors()
      }
    }
  end

  defp errors do
    [
      "should be at most 30 characters",
      "should only contain ASCII characters"
    ]
  end
end
