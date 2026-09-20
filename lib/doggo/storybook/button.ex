defmodule Doggo.Storybook.Button do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def variations(opts) do
    [
      %Variation{
        id: :default,
        slots: ["click me"]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          disabled: true
        },
        slots: ["click me"]
      },
      %Variation{
        id: :busy,
        attributes: %{
          "aria-busy": true,
          "aria-label": "Saving..."
        },
        slots: ["click me"]
      }
    ] ++ fill_groups(opts)
  end

  def skipped_modifier_groups(opts) do
    if fill_groups(opts) == [], do: [], else: [:variant]
  end

  defp fill_groups(opts) do
    modifiers = opts[:modifiers] || []
    variants = modifiers[:variant][:values] || []
    fills = modifiers[:fill][:values] || []

    if fills == [] or variants == [] do
      []
    else
      Enum.map(fills, fn fill ->
        %VariationGroup{
          id: String.to_atom("#{fill}_variants"),
          variations:
            Enum.map(variants, fn variant ->
              %Variation{
                id: String.to_atom("#{fill}_#{variant}"),
                attributes: %{fill: fill, variant: variant},
                slots: [variant]
              }
            end)
        }
      end)
    end
  end

  def modifier_variation_base(_id, _name, value, _opts) do
    %{
      slots: [to_string(value || "nil")]
    }
  end
end
