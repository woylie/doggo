defmodule Doggo.Components.IconSpriteTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_icon_sprite()
  end

  describe "icon_sprite/1" do
    test "renders icon from sprite" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      svg = find_one(span, "svg")
      assert attribute(svg, "aria-hidden") == "true"
      assert attribute(svg, "use", "href") == "/assets/icons/sprite.svg#edit"
    end

    test "renders visually hidden text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" text="some-text" />
        """)

      assert span = find_one(html, "span > span")
      assert attribute(span, "data-visually-hidden") == "data-visually-hidden"
      assert text(span) == "some-text"
    end

    test "renders text before icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" text="some-text" text_position="before" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      assert attribute(span, "data-text-position") == "before"
      assert span = find_one(html, "span > span")
      refute attribute(span, "data-visually-hidden")
      assert text(span) == "some-text"
    end

    test "renders text after icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" text="some-text" text_position="after" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      assert attribute(span, "data-text-position") == "after"
      assert span = find_one(html, "span > span")
      refute attribute(span, "data-visually-hidden")
      assert text(span) == "some-text"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
