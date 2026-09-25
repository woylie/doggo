defmodule Doggo.Components.AvatarTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_avatar()
  end

  describe "avatar/1" do
    test "renders avatar" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" />
        """)

      assert attribute(html, "div:root", "class") == "avatar"
      assert attribute(html, "div:root", "data-size") == "normal"

      img = find_one(html, ":root > img")
      assert attribute(img, "src") == "avatar.png"
      assert attribute(img, "alt") == ""
      assert attribute(img, "loading") == "lazy"
    end

    test "renders size as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" size="large" />
        """)

      assert attribute(html, "div:root", "class") == "avatar"
      assert attribute(html, "div:root", "data-size") == "large"
    end

    test "renders shape as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" shape="circle" />
        """)

      assert attribute(html, "div:root", "class") == "avatar"
      assert attribute(html, "div:root", "data-size") == "normal"
      assert attribute(html, "div:root", "data-shape") == "circle"
    end

    test "renders loading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" loading="eager" />
        """)

      assert attribute(html, ":root > img", "loading") == "eager"
    end

    test "renders alt" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" alt="Avatar" />
        """)

      assert attribute(html, ":root > img", "alt") == "Avatar"
    end

    test "renders hidden text placeholder without src" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src={nil} placeholder_content="A" />
        """)

      assert Floki.find(html, "img") == []
      assert text(html, ":root > span") == "A"

      assert attribute(html, ":root > span", "aria-hidden") == "true"
      assert attribute(html, ":root > span", "role") == nil
    end

    test "names text placeholder with alt" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar
          src={nil}
          placeholder_content="A"
          alt="Alfred Adler"
        />
        """)

      span = find_one(html, ":root > span")
      assert attribute(span, "role") == "img"
      assert attribute(span, "aria-label") == "Alfred Adler"
      assert attribute(span, "aria-hidden") == nil
    end

    test "renders nothing without image or placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src={nil} />
        """)

      assert html == []
    end

    test "renders image placeholder without src" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src={nil} placeholder_src="placeholder.png" />
        """)

      assert attribute(html, ":root > img", "src") == "placeholder.png"
    end

    test "renders alt on image placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar
          src={nil}
          placeholder_src="placeholder.png"
          alt="Alfred Adler"
        />
        """)

      assert attribute(html, ":root > img", "alt") == "Alfred Adler"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
