defmodule Doggo.Storybook.Cluster do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:button, :tag]

  def layout, do: :one_column

  def template do
    """
    <div style="inline-size: 100%">
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        slots: [tags(opts, 12)]
      },
      %Variation{
        id: :with_buttons,
        slots: [buttons(opts)]
      },
      %Variation{
        id: :with_mixed_heights,
        slots: [buttons(opts) <> tags(opts, 3)]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{slots: [tags(opts, 12)]}
  end

  @breeds [
    "Labrador Retriever",
    "German Shepherd",
    "Golden Retriever",
    "Bulldog",
    "Beagle",
    "Poodle",
    "Rottweiler",
    "Yorkshire Terrier",
    "Boxer",
    "Dachshund",
    "Border Collie",
    "Great Dane"
  ]

  defp tags(opts, count) do
    breeds = Enum.take(@breeds, count)

    case opts[:dependent_components][:tag] do
      nil -> Enum.map_join(breeds, "\n", &"<span>#{&1}</span>")
      fun -> Enum.map_join(breeds, "\n", &"<.#{fun}>#{&1}</.#{fun}>")
    end
  end

  defp buttons(opts) do
    Enum.map_join(
      ["Adopt", "Save for later", "Share"],
      "\n",
      &button(&1, ~s|type="button"|, opts[:dependent_components])
    )
  end
end
