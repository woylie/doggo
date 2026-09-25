defmodule Doggo.Components.TabNavigationTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_tab_navigation()
  end

  describe "tab_navigation/1" do
    test "renders tab navigation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation
          current_value={:appointments}
          label="Sections"
        >
          <:item href="/profile" value={:show}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "tab-navigation"
      assert attribute(nav, "aria-label") == "Sections"

      a = find_one(nav, "ul > li > a")
      assert attribute(a, "aria-current") == nil
      assert attribute(a, "href") == "/profile"
    end

    test "marks current item with single value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation
          current_value={:show}
          label="Sections"
        >
          <:item href="/profile" value={:show}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert attribute(a, "aria-current") == "page"
    end

    test "marks current item with list of values" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation
          current_value={:show}
          label="Sections"
        >
          <:item href="/profile" value={[:show, :edit]}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert attribute(a, "aria-current") == "page"
    end

    test "renders label as aria-label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation
          current_value={:appointments}
          label="Tabby"
        >
          <:item href="/profile" value={:show}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Tabby"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation
          current_value={:show}
          label="Sections"
          data-test="hello"
        >
          <:item value={[:show, :edit]}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end
end
