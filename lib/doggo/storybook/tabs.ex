defmodule Doggo.Storybook.Tabs do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def layout, do: :one_column

  def template do
    """
    <div style="inline-size: 100%">
      <.psb-variation/>
    </div>
    """
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "dog-breed-profiles",
          label: "Dog Breed Profiles"
        },
        slots: slots()
      },
      %Variation{
        id: :vertical,
        attributes: %{
          id: "dog-breed-profiles",
          label: "Dog Breed Profiles",
          orientation: "vertical"
        },
        slots: slots()
      },
      %Variation{
        id: :labelledby,
        note: """
        If there already is a heading for the tabs, use `labelledby` to
        reference the existing visible label instead of repeating the text in
        the `label` attribute.
        """,
        template: """
        <div style="inline-size: 100%">
          <h3 id="dog-breed-profiles-heading" style="margin-block: 0 0.75rem">
            Dog breed profiles
          </h3>
          <.psb-variation/>
        </div>
        """,
        attributes: %{
          id: "dog-breed-profiles",
          labelledby: "dog-breed-profiles-heading"
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, _opts) do
    %{
      attributes: %{
        id: id,
        label: "Dog Breed Profiles"
      },
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:panel label="Golden Retriever">
        <p>
          Friendly, intelligent, great with families. Origin: Scotland. Needs
          regular exercise.
        </p>
      </:panel>
      """,
      """
      <:panel label="Siberian Husky">
        <p>
          Energetic, outgoing, distinctive appearance. Origin: Northeast Asia.
          Loves cold climates.
        </p>
      </:panel>
      """,
      """
      <:panel label="Dachshund">
        <p>
          Playful, stubborn, small size. Origin: Germany. Enjoys sniffing games.
        </p>
      </:panel>
      """
    ]
  end
end
