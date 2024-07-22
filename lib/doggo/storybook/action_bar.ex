defmodule Doggo.Storybook.ActionBar do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_, _, _) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:item label="Edit" on_click={JS.push("edit")}>
        <Doggo.icon label="Edit" size={:small}>
          #{edit_svg()}
        </Doggo.icon>
      </:item>
      """,
      """
      <:item label="Move" on_click={JS.push("move")}>
        <Doggo.icon label="Move" size={:small}>
          #{move_svg()}
        </Doggo.icon>
      </:item>
      """,
      """
      <:item label="Archive" on_click={JS.push("archive")}>
        <Doggo.icon label="Archive" size={:small}>
          #{archive_svg()}
        </Doggo.icon>
      </:item>
      """
    ]
  end

  defp edit_svg do
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
      class="lucide lucide-pencil"
      aria-hidden="true"
    >
      <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" /><path d="m15 5 4 4" />
    </svg>
    """
  end

  defp move_svg do
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
      class="lucide lucide-move-right"
      aria-hidden="true"
    >
      <path d="M18 8L22 12L18 16" /><path d="M2 12H22" />
    </svg>
    """
  end

  defp archive_svg do
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
      class="lucide lucide-archive"
      aria-hidden="true"
    >
      <rect width="20" height="5" x="2" y="3" rx="1" /><path d="M4 8v11a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8" /><path d="M10 12h4" />
    </svg>
    """
  end
end
