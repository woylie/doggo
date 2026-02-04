defmodule Doggo.Components.AvatarTest do
  use ExUnit.Case
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
    test "default" do
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

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" size="large" />
        """)

      assert attribute(html, "div:root", "class") == "avatar"
      assert attribute(html, "div:root", "data-size") == "large"
    end

    test "with circle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" shape="circle" />
        """)

      assert attribute(html, "div:root", "class") == "avatar"
      assert attribute(html, "div:root", "data-size") == "normal"
      assert attribute(html, "div:root", "data-shape") == "circle"
    end

    test "with loading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" loading="eager" />
        """)

      assert attribute(html, ":root > img", "loading") == "eager"
    end

    test "with alt" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" alt="Avatar" />
        """)

      assert attribute(html, ":root > img", "alt") == "Avatar"
    end

    test "with text placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src={nil} placeholder_content="A" />
        """)

      assert Floki.find(html, "img") == []
      assert text(html, ":root > span") == "A"
    end

    test "without image or placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src={nil} />
        """)

      assert html == []
    end

    test "with image placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src={nil} placeholder_src="placeholder.png" />
        """)

      assert attribute(html, ":root > img", "src") == "placeholder.png"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.avatar src="avatar.png" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
