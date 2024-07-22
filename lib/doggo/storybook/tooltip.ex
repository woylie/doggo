defmodule Doggo.Storybook.Tooltip do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :with_text,
        attributes: %{
          id: "labrador-info-1"
        },
        slots: slots_with_text()
      },
      %Variation{
        id: :with_link,
        attributes: %{
          contains_link: true,
          id: "labrador-info-2"
        },
        slots: slots_with_link()
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, _opts) do
    %{
      attributes: %{id: id},
      slots: slots_with_text()
    }
  end

  def slots_with_text do
    [
      "Labrador Retriever",
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

  def slots_with_link do
    [
      """
      <Phoenix.Component.link navigate="/labradors">
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
