defmodule Doggo.Components.FrameTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_frame()
  end

  describe "frame/1" do
    test "renders square ratio by default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.frame>image</TestComponents.frame>
        """)

      assert attribute(html, "div", "data-numerator") == "1"
      assert attribute(html, "div", "data-denominator") == "1"
    end

    test "renders ratio as data attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.frame ratio="16:9">image</TestComponents.frame>
        """)

      assert attribute(html, "div", "class") == "frame"
      assert attribute(html, "div", "data-numerator") == "16"
      assert attribute(html, "div", "data-denominator") == "9"
    end

    test "renders shape as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.frame ratio="16:9" shape="circle">image</TestComponents.frame>
        """)

      assert attribute(html, "div", "class") == "frame"
      assert attribute(html, "div", "data-shape") == "circle"
    end
  end
end
