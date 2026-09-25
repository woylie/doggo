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
    build_frame(name: :wide_frame, ratios: ["21:9", "16:9"])
    build_frame(name: :plain_frame, modifiers: [])
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

    test "renders no ratio for value outside ratios" do
      assigns = %{ratio: "7:3"}

      html =
        parse_heex(~H"""
        <TestComponents.frame ratio={@ratio}>image</TestComponents.frame>
        """)

      assert attribute(html, "div", "data-numerator") == nil
      assert attribute(html, "div", "data-denominator") == nil
    end

    test "renders first of ratios by default with ratios option" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.wide_frame>image</TestComponents.wide_frame>
        """)

      assert attribute(html, "div", "data-numerator") == "21"
      assert attribute(html, "div", "data-denominator") == "9"
    end

    test "renders ratio without modifiers" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.plain_frame ratio="4:3">image</TestComponents.plain_frame>
        """)

      assert attribute(html, "div", "data-numerator") == "4"
      assert attribute(html, "div", "data-denominator") == "3"
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
