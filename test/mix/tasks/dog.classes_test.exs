defmodule Mix.Tasks.Dog.ClassesTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Mix.Tasks.Dog.Classes

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_button(
      base_class: "my-button",
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

  test "prints classes" do
    assert capture_io(fn ->
             Classes.run([
               "--module",
               "Mix.Tasks.Dog.ClassesTest.TestComponents"
             ])
           end) == """
           is-normal
           is-primary
           is-secondary
           is-small
           my-button
           """
  end

  test "prints usage instructions with invalid arguments" do
    assert capture_io(fn -> Classes.run(["--nope"]) end) =~ "## Usage"
  end

  @tag :tmp_dir
  test "saves modifiers to file", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "classes.txt")

    assert capture_io(fn ->
             Classes.run([
               "--module",
               "Mix.Tasks.Dog.ClassesTest.TestComponents",
               "-o",
               path
             ])
           end)

    assert File.exists?(path)

    classes_in_file = extract_classes(path)

    assert classes_in_file ==
             [
               "is-normal",
               "is-primary",
               "is-secondary",
               "is-small",
               "my-button"
             ]
  end

  @tag :tmp_dir
  test "checks whether existing file is up-to-date", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "classes.txt")

    assert capture_io(fn ->
             Classes.run([
               "--module",
               "Mix.Tasks.Dog.ClassesTest.TestComponents",
               "-o",
               path
             ])
           end)

    assert File.exists?(path)

    assert capture_io(fn ->
             Classes.run([
               "--module",
               "Mix.Tasks.Dog.ClassesTest.TestComponents",
               "-o",
               path,
               "--check"
             ])
           end) =~ "up to date"

    File.write!(path, "is-normal\n")

    assert catch_exit(
             capture_io(fn ->
               Classes.run([
                 "--module",
                 "Mix.Tasks.Dog.ClassesTest.TestComponents",
                 "-o",
                 path,
                 "--check"
               ])
             end)
           ) == {:shutdown, 1}
  end

  defp extract_classes(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(fn s -> s == "" || String.starts_with?(s, "#") end)
  end
end
