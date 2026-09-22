defmodule Doggo.Storybook.Image do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def layout, do: :one_column

  def template do
    """
    <div style="inline-size: 20rem">
      <.psb-variation/>
    </div>
    """
  end

  def modifier_variation_group_template(_name, _opts) do
    """
    <style>
      .psb-gallery {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(8rem, 1fr));
        gap: 1rem;
        align-items: start;
      }

      .psb-gallery > * {
        position: relative;
      }

      .psb-gallery > *::after {
        content: attr(data-label);
        position: absolute;
        inset-block-start: 0.25rem;
        inset-inline-start: 0.25rem;
        padding: 0.125rem 0.375rem;
        font-size: 0.75rem;
        color: #fff;
        background: rgb(0 0 0 / 65%);
        border-radius: 0.25rem;
      }
    </style>
    <div class="psb-gallery">
      <.psb-variation-group/>
    </div>
    """
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: attributes()
      },
      %Variation{
        id: :responsive,
        attributes:
          Map.merge(attributes(), %{
            srcset:
              "https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true 1200w",
            sizes: "(min-width: 40rem) 20rem, 100vw",
            width: 1200,
            height: 675,
            loading: "eager"
          })
      },
      %Variation{
        id: :caption,
        attributes: attributes(),
        slots: [
          """
          <:caption>Canine couture, spring collection: the season's boldest silhouettes, worn on four legs.</:caption>
          """
        ]
      }
    ]
  end

  def modifier_variation_base(_id, _name, value, _opts) do
    %{
      attributes:
        Map.put(attributes(), :"data-label", to_string(value || "none"))
    }
  end

  defp attributes do
    %{
      src:
        "https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true",
      alt: "A gray-muzzled dog in a camouflage coat and harness.",
      ratio: "16:9"
    }
  end
end
