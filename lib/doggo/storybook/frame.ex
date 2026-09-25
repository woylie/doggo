defmodule Doggo.Storybook.Frame do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def layout, do: :one_column

  def variations(opts) do
    [
      %Variation{
        id: :default,
        slots: slots()
      },
      %VariationGroup{
        id: :ratio,
        template: ratio_template(),
        variations:
          Enum.map(opts[:extra][:ratios], fn ratio ->
            %Variation{
              id: String.to_atom("ratio_#{String.replace(ratio, ":", "_")}"),
              attributes: %{ratio: ratio, "data-label": ratio},
              slots: slots()
            }
          end)
      }
    ]
  end

  def template do
    """
    <div style="inline-size: 16rem">
      <.psb-variation/>
    </div>
    """
  end

  defp ratio_template do
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

  def modifier_variation_group_template(_name, _opts) do
    """
    <style>
      .psb-gallery {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(8rem, 1fr));
        gap: 1rem;
        align-items: start;
      }
    </style>
    <div class="psb-gallery">
      <.psb-variation-group/>
    </div>
    """
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <img
        src="https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true"
        alt="A gray-muzzled dog in a camouflage coat and harness."
      />
      """
    ]
  end
end
