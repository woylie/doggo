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

  describe "build_icon_sprite/1 with an expression as sprite_url" do
    test "evaluates the URL at render time" do
      defmodule WithRenderURL do
        use Doggo.Components
        use Phoenix.Component

        build_icon_sprite(sprite_url: Process.get(:sprite_url, "/icons.svg"))
      end

      assigns = %{}
      Process.put(:sprite_url, "/icons-3f2a.svg")

      html =
        parse_heex(~H"""
        <WithRenderURL.icon_sprite name="edit" />
        """)

      assert attribute(find_one(html, "use"), "href") == "/icons-3f2a.svg#edit"
    end
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

    test "renders visually hidden label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" label="some-text" />
        """)

      assert span = find_one(html, "span > span")
      assert attribute(span, "data-visually-hidden") == "data-visually-hidden"
      assert text(span) == "some-text"
    end

    test "renders label before icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite
          name="edit"
          label="some-text"
          label_position="before"
        />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      assert attribute(span, "data-label-position") == "before"
      assert span = find_one(html, "span > span")
      refute attribute(span, "data-visually-hidden")
      assert text(span) == "some-text"
    end

    test "renders label after icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite
          name="edit"
          label="some-text"
          label_position="after"
        />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      assert attribute(span, "data-label-position") == "after"
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

    test "raises for blank label" do
      assert_raise ArgumentError, ~r/blank label for/, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" label="" />
        """)
      end
    end
  end
end
