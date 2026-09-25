defmodule Doggo.Components.SkeletonTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_skeleton()
  end

  describe "skeleton/1" do
    test "renders skeleton" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.skeleton type="circle" />
        """)

      assert attribute(html, "div:root", "class") == "skeleton"
      assert attribute(html, "div:root", "data-type") == "circle"
    end

    test "renders type as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.skeleton type="text-block" />
        """)

      assert attribute(html, "div:root", "class") == "skeleton"
      assert attribute(html, "div:root", "data-type") == "text-block"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.skeleton type="square" data-test="hello" />
        """)

      assert attribute(html, "div:root", "data-test") == "hello"
    end
  end
end
