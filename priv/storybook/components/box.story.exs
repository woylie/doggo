defmodule Storybook.Components.Box do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.box/1

  def variations do
    [
      %Variation{
        id: :minimal,
        slots: [
          "<p>This is a box.</p>"
        ]
      },
      %Variation{
        id: :title_action_footer,
        description: "With title, action, and footer",
        slots: [
          "<:title>Profile</:title>",
          "<p>This is a box.</p>",
          """
          <:action>
            <Doggo.button_link patch="/profiles/1/edit">Edit</Doggo.button_link>
          </:action>
          """,
          """
          <:footer>
            <p>Last edited: 2023/12/26</p>
          </:footer>
          """
        ]
      },
      %Variation{
        id: :banner,
        description: "With banner",
        slots: [
          "<:title>Profile</:title>",
          """
          <:banner>
            <img
              src="https://github.com/woylie/doggo/blob/main/dog_poncho.jpg?raw=true"
              alt=""
            />
          </:banner>
          """,
          "<p>This is a box.</p>",
          """
          <:action>
            <Doggo.button_link patch="/profiles/1/edit">Edit</Doggo.button_link>
          </:action>
          """,
          """
          <:footer>
            <p>Last edited: 2023/12/26</p>
          </:footer>
          """
        ]
      }
    ]
  end
end
