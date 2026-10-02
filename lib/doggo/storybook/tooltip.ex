if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.Tooltip do
    @moduledoc false
    alias PhoenixStorybook.Stories.Variation

    def variations(_opts) do
      [
        %Variation{
          id: :with_button,
          note:
            "The inner block receives the attributes that point " <>
              "`aria-describedby` at the tooltip, and spreads them on the button.",
          attributes: %{id: "delete-info-1"},
          let: :trigger,
          slots: slots_with_button()
        },
        %Variation{
          id: :with_link,
          attributes: %{id: "labrador-info-2"},
          let: :trigger,
          slots: slots_with_link()
        }
      ]
    end

    def modifier_variation_base(id, _name, _value, _opts) do
      %{
        attributes: %{id: id},
        let: :trigger,
        slots: slots_with_button()
      }
    end

    def slots_with_button do
      [
        """
        <button type="button" {trigger}>Delete</button>
        """,
        """
        <:tooltip>Deletes the row and its history.</:tooltip>
        """
      ]
    end

    def slots_with_link do
      [
        """
        <Phoenix.Component.link navigate="/labradors" {trigger}>
          Labrador Retriever
        </Phoenix.Component.link>
        """,
        """
        <:tooltip>
          <p><strong>Labrador Retriever</strong></p>
          <p>
            Labradors are known for their friendly nature and excellent
            swimming abilities.
          </p>
        </:tooltip>
        """
      ]
    end
  end
end
