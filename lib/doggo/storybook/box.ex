defmodule Doggo.Storybook.Box do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

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
        slots: slots()
      },
      %Variation{
        id: :banner,
        description: "With banner",
        slots: [
          "<:title>Profile</:title>",
          """
          <:banner>
            <img
              src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
              alt=""
            />
          </:banner>
          """,
          "<p>This is a box.</p>",
          """
          <:action>
            <Phoenix.Component.link patch="/profiles/1/edit">Edit</Phoenix.Component.link>
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

  def modifier_variation(_, _) do
    %{
      attributes: %{},
      slots: slots()
    }
  end

  defp slots do
    [
      "<:title>Profile</:title>",
      "<p>This is a box.</p>",
      """
      <:action>
        <Phoenix.Component.link patch="/profiles/1/edit">Edit</Phoenix.Component.link>
      </:action>
      """,
      """
      <:footer>
        <p>Last edited: 2023/12/26</p>
      </:footer>
      """
    ]
  end
end
