defmodule Doggo.Storybook.Box do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def layout, do: :one_column

  def variations(_opts) do
    [
      %Variation{
        id: :minimal,
        slots: [body()]
      },
      %Variation{
        id: :title_action_footer,
        description: "With title, action, and footer",
        slots: [title(), body(), action(), footer()]
      },
      %Variation{
        id: :heading_level,
        note:
          "The `heading` should be chosen to follow the header hierarchy in the document outline.",
        attributes: %{heading: "h3"},
        slots: [title(), body()]
      },
      %Variation{
        id: :banner,
        description: "With banner and title",
        slots: [title(), banner(), body()]
      },
      %Variation{
        id: :banner_without_title,
        description: "With banner, without title",
        slots: [banner(), body()]
      },
      %Variation{
        id: :action_without_title,
        description: "Action without title",
        slots: [body(), action()]
      },
      %Variation{
        id: :footer_only,
        description: "No header",
        slots: [body(), footer()]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{slots: [title(), body(), action(), footer()]}
  end

  defp title do
    "<:title>Adopt a Loyal Friend</:title>"
  end

  defp action do
    """
    <:action>
      <.link patch="/profiles/1/edit">Edit</.link>
    </:action>
    """
  end

  defp footer do
    """
    <:footer>
      <p>Last edited: 2023/12/26</p>
    </:footer>
    """
  end

  defp banner do
    """
    <:banner>
      <img
        src="https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true"
        alt=""
      />
    </:banner>
    """
  end

  defp body do
    """
    <p>
      Dogs are known for their loyalty and companionship. Whether you're
      looking for a playful pup or a calm and cuddly companion, there's a dog
      out there waiting for you. From energetic retrievers to gentle lap dogs,
      each breed has its own unique traits that can match your lifestyle.
      Visit your local shelter today to find the perfect furry friend to bring
      joy and love into your home
    </p>
    """
  end
end
