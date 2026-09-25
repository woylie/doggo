defmodule Doggo.Components.TagTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_tag()
  end

  describe "tag/1" do
    test "renders tag" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag>value</TestComponents.tag>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "tag"
      assert attribute(span, "data-size") == "normal"
      assert text(span) == "value"
    end

    test "renders size as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag size="medium">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag"
      assert attribute(html, "span", "data-size") == "medium"
    end

    test "renders variant as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag variant="primary">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag"
      assert attribute(html, "span", "data-variant") == "primary"
    end

    test "renders shape as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag shape="pill">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag"
      assert attribute(html, "span", "data-shape") == "pill"
      assert attribute(html, "span", "data-size") == "normal"
    end
  end
end
