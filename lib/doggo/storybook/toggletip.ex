if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.Toggletip do
    @moduledoc false
    alias PhoenixStorybook.Stories.Variation

    def variations(_opts) do
      [
        %Variation{
          id: :with_icon,
          note:
            "The label names the button for screen readers; the icon is " <>
              "hidden from them.",
          attributes: %{
            id: "adoption-fee-info-1",
            label: "About the adoption fee"
          },
          slots: slots_with_icon()
        },
        %Variation{
          id: :with_text,
          attributes: %{
            id: "adoption-fee-info-2",
            label: "What does the fee cover?"
          },
          slots: slots_with_text()
        },
        %Variation{
          id: :with_link,
          note:
            "The panel may hold links, which `Tab` reaches from the button.",
          attributes: %{
            id: "adoption-fee-info-3",
            label: "About the adoption fee"
          },
          slots: slots_with_link()
        }
      ]
    end

    def modifier_variation_base(id, _name, _value, _opts) do
      %{
        attributes: %{id: id, label: "About the adoption fee"},
        slots: slots_with_text()
      }
    end

    def slots_with_icon do
      [
        "<:icon>ⓘ</:icon>",
        "The fee covers vaccinations, a microchip and the first vet visit."
      ]
    end

    def slots_with_text do
      ["The fee covers vaccinations, a microchip and the first vet visit."]
    end

    def slots_with_link do
      [
        "<:icon>ⓘ</:icon>",
        """
        <p>The fee covers vaccinations, a microchip and the first vet visit.</p>
        <p>
          <Phoenix.Component.link navigate="/adoption/fees">
            How fees are used
          </Phoenix.Component.link>
        </p>
        """
      ]
    end
  end
end
