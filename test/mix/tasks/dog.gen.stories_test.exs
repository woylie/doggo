defmodule Mix.Tasks.Dog.GenStoriesTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Mix.Tasks.Dog.Gen.Stories

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_button()
    build_menu(name: :context_menu)
  end

  @tag :tmp_dir
  test "saves modifiers to file", %{tmp_dir: tmp_dir} do
    assert capture_io(fn ->
             Stories.run([
               "--module",
               "Mix.Tasks.Dog.GenStoriesTest.TestComponents",
               "-o",
               tmp_dir
             ])
           end)

    button_path = Path.join([tmp_dir, "buttons", "button.story.exs"])
    menu_path = Path.join([tmp_dir, "menu", "context_menu.story.exs"])

    assert File.exists?(button_path)

    {formatter, _} = Mix.Tasks.Format.formatter_for_file(button_path)

    assert File.read!(button_path) ==
             formatter.(Doggo.Storybook.story_template(TestComponents, :button))

    assert File.exists?(menu_path)

    assert File.read!(menu_path) ==
             formatter.(
               Doggo.Storybook.story_template(TestComponents, :context_menu)
             )
  end
end
