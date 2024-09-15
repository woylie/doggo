defmodule Doggo.Storybook.Box do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:button_link]

  def container, do: {:div, class: :container}
  def layout, do: :one_column

  def variations(opts) do
    [
      %Variation{
        id: :minimal,
        slots: [
          body()
        ]
      },
      %Variation{
        id: :title_action_footer,
        description: "With title, action, and footer",
        slots: slots(:title_action_footer, opts)
      },
      %Variation{
        id: :banner,
        description: "With banner",
        slots: with_banner_slots(:banner, opts)
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, opts) do
    %{
      slots: slots(id, opts)
    }
  end

  defp slots(_id, _opts) do
    [
      "<:title>Adopt a Loyal Friend</:title>",
      body(),
      """
      <:action>
        <.link patch="/profiles/1/edit">Edit</.link>
      </:action>
      """,
      """
      <:footer>
        <p>Last edited: 2023/12/26</p>
      </:footer>
      """
    ]
  end

  defp with_banner_slots(_id, _opts) do
    [
      "<:title>Adopt a Loyal Friend</:title>",
      """
      <:banner>
        <img
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt=""
        />
      </:banner>
      """,
      body(),
      """
      <:action>
        <.link patch="/profiles/1/edit">Edit</.link>
      </:action>
      """,
      """
      <:footer>
        <p>Last edited: 2023/12/26</p>
      </:footer>
      """
    ]
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
