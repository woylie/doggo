defmodule Storybook.MyPage do
  # See https://hexdocs.pm/phoenix_storybook/PhoenixStorybook.Story.html for full story
  # documentation.
  use PhoenixStorybook.Story, :page

  def doc, do: "Welcome to Doggo"

  def render(assigns) do
    ~H"""
    <div class="psb-welcome-page">
      <p>
        This is the storybook of the Doggo demo application. All components were
        generated with the default options. The stories were generated with
        <code>mix dog.gen.stories -m DemoWeb.CoreComponents -o storybook</code>.
      </p>

      <p>
        Keep in mind that Doggo is headless, which means that it doesn't come
        with any default styles.
      </p>
    </div>
    """
  end
end
