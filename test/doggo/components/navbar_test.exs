defmodule Doggo.Components.NavbarTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_navbar()
  end

  describe "navbar/1" do
    test "renders navbar" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar label="Main">content</TestComponents.navbar>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "navbar"
      assert attribute(nav, "aria-label") == "Main"
      assert text(nav) == "content"
      assert Floki.find(html, ".navbar-brand") == []
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar labelledby="nav-heading">content</TestComponents.navbar>
        """)

      assert attribute(html, "nav:root", "aria-label") == nil
      assert attribute(html, "nav:root", "aria-labelledby") == "nav-heading"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.navbar label="Main" labelledby="nav-heading">
          content
        </TestComponents.navbar>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.navbar>content</TestComponents.navbar>
        """)
      end
    end

    test "raises for blank label" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.navbar label=" ">content</TestComponents.navbar>
        """)
      end
    end

    test "renders brand" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar label="Main">
          <:brand>Doggo</:brand>
          content
        </TestComponents.navbar>
        """)

      div = find_one(html, ":root > .navbar-brand")
      assert text(div) == "Doggo"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar label="Main" data-test="hello">
          content
        </TestComponents.navbar>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
