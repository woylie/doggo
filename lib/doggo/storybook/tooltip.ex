defmodule Doggo.Storybook.Tooltip do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :with_text,
        note:
          "The component makes the text focusable and points " <>
            "`aria-describedby` at the tooltip.",
        attributes: %{
          id: "labrador-info-1"
        },
        slots: slots_with_text()
      },
      %Variation{
        id: :with_link,
        note:
          "The link takes the focus, so the link takes `aria-describedby`. " <>
            "The component sets neither attribute here.",
        attributes: %{
          contains_link: true,
          id: "labrador-info-2"
        },
        slots: slots_with_link("labrador-info-2")
      },
      %Variation{
        id: :with_link_in_tooltip,
        note:
          "The link is reachable: focusing it keeps the tooltip open, and " <>
            "`Esc` still dismisses. But a screen reader reads a description " <>
            "as text, so the link is announced without being announced as a " <>
            "link. The ARIA Authoring Practices advise against interactive " <>
            "content in a tooltip for that reason.",
        attributes: %{
          id: "labrador-info-3"
        },
        slots: slots_with_link_in_tooltip()
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

  def slots_with_link(id) do
    [
      """
      <Phoenix.Component.link
        navigate="/labradors"
        aria-describedby="#{id}-tooltip"
      >
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

  def slots_with_link_in_tooltip do
    [
      "Labrador Retriever",
      """
      <:tooltip>
        <p><strong>Labrador Retriever</strong></p>
        <p>
          Labradors are known for their friendly nature and excellent
          swimming abilities.
        </p>
        <p>
          <Phoenix.Component.link navigate="/labradors">
            More about Labradors
          </Phoenix.Component.link>
        </p>
      </:tooltip>
      """
    ]
  end
end
