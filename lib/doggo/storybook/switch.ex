defmodule Doggo.Storybook.Switch do
  @moduledoc false

  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  defp stacked do
    """
    <div style="display: grid; gap: 0.75rem">
      <.psb-variation-group/>
    </div>
    """
  end

  defp toggle do
    {:eval,
     """
     %JS{}
     |> JS.toggle_attribute({"aria-checked", "true", "false"})
     |> JS.toggle_attribute({"hidden", "true"}, to: {:inner, ".switch-state-on"})
     |> JS.toggle_attribute({"hidden", "true"}, to: {:inner, ".switch-state-off"})
     """}
  end

  def variations(_opts) do
    [
      %VariationGroup{
        id: :default,
        template: stacked(),
        variations: [
          %Variation{
            id: :on,
            attributes: %{
              label: "Email notifications",
              checked: true,
              "phx-click": toggle()
            }
          },
          %Variation{
            id: :off,
            attributes: %{
              label: "Two-factor authentication",
              checked: false,
              "phx-click": toggle()
            }
          }
        ]
      },
      %VariationGroup{
        id: :custom_text,
        template: stacked(),
        variations: [
          %Variation{
            id: :on,
            attributes: %{
              label: "Public profile",
              on_text: "yes",
              off_text: "no",
              checked: true,
              "phx-click": toggle()
            }
          },
          %Variation{
            id: :off,
            attributes: %{
              label: "Show activity status",
              on_text: "yes",
              off_text: "no",
              checked: false,
              "phx-click": toggle()
            }
          }
        ]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        label: "Email notifications",
        checked: true,
        "phx-click": toggle()
      }
    }
  end
end
