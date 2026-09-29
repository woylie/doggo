defmodule Doggo.Components.DrawerTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_drawer()
  end

  describe "drawer/1" do
    test "renders drawer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer-1">
          <:main>Content</:main>
        </TestComponents.drawer>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "drawer"
    end

    test "renders header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer-2">
          <:header>Doggo</:header>
        </TestComponents.drawer>
        """)

      assert text(html, "div > div.drawer-header") == "Doggo"
    end

    test "names drawer by header with navigation role" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer-2" role="navigation">
          <:header>Doggo</:header>
        </TestComponents.drawer>
        """)

      assert attribute(html, "div:root", "role") == "navigation"
      assert attribute(html, "div:root", "aria-labelledby") == "drawer-2-header"
    end

    test "omits name with role nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer-2" role={nil}>
          <:header>Doggo</:header>
        </TestComponents.drawer>
        """)

      assert attribute(html, "div:root", "role") == nil
      assert attribute(html, "div:root", "aria-labelledby") == nil
    end

    test "renders main" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer-3">
          <:main>Doggo</:main>
        </TestComponents.drawer>
        """)

      assert text(html, "div > div.drawer-main") == "Doggo"
    end

    test "renders footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer-4">
          <:footer>Doggo</:footer>
        </TestComponents.drawer>
        """)

      assert text(html, "div > div.drawer-footer") == "Doggo"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer-5" data-what="ever">
          <:main>Content</:main>
        </TestComponents.drawer>
        """)

      assert attribute(html, "div:root", "data-what") == "ever"
    end

    test "renders nothing without slots" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer id="drawer" />
        """)

      assert html == []
    end
  end
end
