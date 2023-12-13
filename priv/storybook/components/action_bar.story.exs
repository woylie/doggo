defmodule Storybook.Components.ActionBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.action_bar/1

  def variations do
    [
      %Variation{
        id: :default,
        description: """
        Note that the actual icons have been omitted from this example,
        since Doggo does not ship with a default icon library.
        """,
        slots: [
        """
        <:item label="Edit" on_click={JS.push("edit")}>
          <Doggo.icon size={:small}>Edit</Doggo.icon>
        </:item>
        """,
        """
        <:item label="Move" on_click={JS.push("move")}>
          <Doggo.icon size={:small}>Move</Doggo.icon>
        </:item>
        """,
        """
        <:item label="Archive" on_click={JS.push("archive")}>
          <Doggo.icon size={:small}>Archive</Doggo.icon>
        </:item>
        """
        ]
      }
    ]
  end
end