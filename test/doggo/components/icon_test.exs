defmodule Doggo.Components.IconTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule Icons do
    use Phoenix.Component

    def render(assigns) do
      ~H"""
      <svg class={@name}></svg>
      """
    end

    def info(assigns) do
      ~H"""
      <svg class="info"></svg>
      """
    end
  end

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_icon(icon_module: Doggo.Components.IconTest.Icons)

    build_icon(
      icon_module: Doggo.Components.IconTest.Icons,
      icon_fun: :render,
      name: :icon_with_fun
    )
  end

  describe "icon/1" do
    test "renders icon from module" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"

      assert find_one(html, "svg.info")
    end

    test "renders icon from module with function" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_with_fun name="warning" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"

      assert find_one(html, "svg.warning")
    end

    test "renders visually hidden text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" text="some-text" />
        """)

      assert span = find_one(html, "span > span")
      assert attribute(span, "data-visually-hidden") == "data-visually-hidden"
      assert text(span) == "some-text"

      assert find_one(html, "svg.info")
    end

    test "renders text before icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" text="some-text" text_position="before" />
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
        <TestComponents.icon name="info" text="some-text" text_position="after" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      assert attribute(span, "data-text-position") == "after"
      assert span = find_one(html, "span > span")
      refute attribute(span, "data-visually-hidden") == ""
      assert text(span) == "some-text"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
