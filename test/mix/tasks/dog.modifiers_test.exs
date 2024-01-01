defmodule Mix.Tasks.Dog.ModifiersTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Mix.Tasks.Dog.Modifiers

  test "prints modifiers" do
    assert capture_io(fn -> Modifiers.run([]) end) =~ "is-small\n"
  end

  test "prints usage instructions with invalid arguments" do
    assert capture_io(fn -> Modifiers.run(["--nope"]) end) =~ "## Usage"
  end

  @tag :tmp_dir
  test "saves modifiers to file", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "modifiers.txt")
    assert capture_io(fn -> Modifiers.run(["-o", path]) end)
    assert File.exists?(path)
  end
end
