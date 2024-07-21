defmodule Doggo.Storybook.Tree do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Dogs"
        },
        slots: slots()
      },
      %Variation{
        id: :with_icons,
        attributes: %{
          label: "Dogs"
        },
        slots: slots_with_icons()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, label: "Dogs"},
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <Doggo.tree_item>
        Breeds
        <:items>
          <Doggo.tree_item>Golden Retriever</Doggo.tree_item>
          <Doggo.tree_item>Labrador Retriever</Doggo.tree_item>
        </:items>
      </Doggo.tree_item>
      <Doggo.tree_item>
        Characteristics
        <:items>
          <Doggo.tree_item>Playful</Doggo.tree_item>
          <Doggo.tree_item>Loyal</Doggo.tree_item>
        </:items>
      </Doggo.tree_item>
      """
    ]
  end

  defp slots_with_icons do
    [
      """
      <Doggo.tree_item>
        #{folder_svg()} Breeds
        <:items>
          <Doggo.tree_item>
            #{paw_svg()} Golden Retriever
          </Doggo.tree_item>
          <Doggo.tree_item>
            #{paw_svg()} Labrador Retriever
          </Doggo.tree_item>
        </:items>
      </Doggo.tree_item>
      <Doggo.tree_item>
        #{folder_svg()} Characteristics
        <:items>
          <Doggo.tree_item>
            #{paw_svg()} Playful
          </Doggo.tree_item>
          <Doggo.tree_item>
            #{paw_svg()} Loyal
          </Doggo.tree_item>
        </:items>
      </Doggo.tree_item>
      """
    ]
  end

  def folder_svg do
    """
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="lucide lucide-folder"
    >
      <path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z" />
    </svg>
    """
  end

  def paw_svg do
    """
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="lucide lucide-paw-print"
    >
      <circle cx="11" cy="4" r="2" />
      <circle cx="18" cy="8" r="2" />
      <circle cx="20" cy="16" r="2" />
      <path d="M9 10a5 5 0 0 1 5 5v3.5a3.5 3.5 0 0 1-6.84 1.045Q6.52 17.48 4.46 16.84A3.5 3.5 0 0 1 5.5 10Z" />
    </svg>
    """
  end

  def like_svg do
    """
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="lucide lucide-heart"
      aria-hidden="true"
    >
      <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z" />
    </svg>
    """
  end
end
