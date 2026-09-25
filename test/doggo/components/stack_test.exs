defmodule Doggo.Components.StackTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_stack()
  end

  describe "stack/1" do
    test "renders stack" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack>Hello</TestComponents.stack>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "stack"
      refute attribute(html, "div", "data-recursive")
      assert text(div) == "Hello"
    end

    test "renders recursive as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack recursive>Hello</TestComponents.stack>
        """)

      assert attribute(html, "div", "class") == "stack"
      assert attribute(html, "div", "data-recursive") == "data-recursive"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack data-what="ever">Hello</TestComponents.stack>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end
end
