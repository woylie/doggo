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
        <TestComponents.drawer id="drawer-1"></TestComponents.drawer>
        """)

      div = find_one(html, "div")
      assert attribute(div, "class") == "drawer"
      assert Floki.children(div) == []
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
        <TestComponents.drawer id="drawer-5" data-what="ever"></TestComponents.drawer>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end
end
