defmodule Doggo.Components.BadgeTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_badge()
  end

  describe "badge/1" do
    test "renders badge" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge>value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge"
      assert attribute(span, "data-size") == "normal"
      assert text(span) == "value"
    end

    test "renders size as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge size="large">value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge"
      assert attribute(span, "data-size") == "large"
    end

    test "renders variant as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge variant="secondary">value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge"
      assert attribute(span, "data-variant") == "secondary"
      assert attribute(span, "data-size") == "normal"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge data-what="ever">value</TestComponents.badge>
        """)

      assert attribute(html, "span", "data-what") == "ever"
    end
  end
end
