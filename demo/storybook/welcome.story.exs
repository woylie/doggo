defmodule Storybook.MyPage do
  # See https://hexdocs.pm/phoenix_storybook/PhoenixStorybook.Story.html for full story
  # documentation.
  use PhoenixStorybook.Story, :page

  def doc, do: "Welcome to Doggo"

  def render(assigns) do
    ~H"""
    <div class="psb-welcome-page">
      <p>Doggo is a headless component library for Phoenix LiveView. <em>Headless UI</em> refers to components that provide the logic and structure needed to build user interfaces but leave the styling up to you.</p>
      <p>This storybook presents the components with their default options. Some components already include example styles, while others remain unstyled and will receive example styles in the future.</p>
      <p>You can override the default options, including component names, base classes, and modifier attributes such as button sizes or variants.</p>
      <p>The library includes a mix task to generate storybook stories for the components configured in your application.</p>
      <p>For details about component maturity and configuration options, please refer to the <a href="https://hexdocs.pm/doggo/Doggo.Components.html" target="_blank">Components documentation</a></p>

      <h2>Resources</h2>
      <ul>
        <li><a href="https://github.com/woylie/doggo" target="_blank">Github repository</a></li>
        <li><a href="https://hexdocs.pm/doggo/readme.html" target="_blank">Installation and usage</a></li>
        <li><a href="https://hexdocs.pm/doggo/Doggo.Components.html" target="_blank">Components documentation</a></li>
        <li><a href="https://hexdocs.pm/doggo/Mix.Tasks.Dog.Gen.Stories.html" target="_blank">Story generator task</a></li>
      </ul>
    </div>
    """
  end
end
