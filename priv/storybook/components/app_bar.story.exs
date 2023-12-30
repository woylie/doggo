defmodule Storybook.Components.AppBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.app_bar/1

  def menu_svg do
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
      class="lucide lucide-menu"
      aria-hidden="true"
    >
      <line x1="4" x2="20" y1="12" y2="12" /><line x1="4" x2="20" y1="6" y2="6" /><line
        x1="4"
        x2="20"
        y1="18"
        y2="18"
      />
    </svg>
    """
  end

  def search_svg do
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
      class="lucide lucide-search"
      aria-hidden="true"
    >
      <circle cx="11" cy="11" r="8" /><path d="m21 21-4.3-4.3" />
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

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          title: "Page title"
        },
        slots: [
          """
          <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
            <Doggo.icon label="Menu">#{menu_svg()}</Doggo.icon>
          </:navigation>
          """,
          """
          <:action label="Search" on_click={JS.push("search")}>
            <Doggo.icon label="Search">#{search_svg()}</Doggo.icon>
          </:action>
          """,
          """
          <:action label="Like" on_click={JS.push("like")}>
            <Doggo.icon label="Like">#{like_svg()}</Doggo.icon>
          </:action>
          """
        ]
      }
    ]
  end
end
