defmodule Mix.Tasks.Dog.ModifiersTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Mix.Tasks.Dog.Modifiers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    button(
      modifiers: [
        size: [values: ["small", "normal"], default: "normal"],
        variant: [
          values: [
            nil,
            "primary",
            "secondary"
          ],
          default: nil
        ]
      ]
    )
  end

  test "prints modifiers" do
    assert capture_io(fn ->
             Modifiers.run([
               "--module",
               "Mix.Tasks.Dog.ModifiersTest.TestComponents"
             ])
           end) == "is-normal\nis-primary\nis-secondary\nis-small\n"
  end

  test "prints usage instructions with invalid arguments" do
    assert capture_io(fn -> Modifiers.run(["--nope"]) end) =~ "## Usage"
  end

  @tag :tmp_dir
  test "saves modifiers to file", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "modifiers.txt")

    assert capture_io(fn ->
             Modifiers.run([
               "--module",
               "Mix.Tasks.Dog.ModifiersTest.TestComponents",
               "-o",
               path
             ])
           end)

    assert File.exists?(path)
    assert File.read!(path) == "is-normal\nis-primary\nis-secondary\nis-small"
  end
end
