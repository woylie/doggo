defmodule Storybook.ModifierClasses do
  use PhoenixStorybook.Story, :page

  def render(assigns) do
    ~H"""
    <div class="lsb-welcome-page">
      <p>
        Doggo makes use of modifier CSS classes to alter the appearance of
        components. Here's a complete list:
      </p>

      <div :for={{type, classes} <- Doggo.modifier_classes()}>
        <h3><%= to_titlecase(type) %></h3>
        <ul>
          <li :for={class <- classes}><%= class %></li>
        </ul>
      </div>
    </div>
    """
  end

  defp to_titlecase(s) do
    s
    |> to_string()
    |> String.replace("_", " ")
    |> :string.titlecase()
  end
end
