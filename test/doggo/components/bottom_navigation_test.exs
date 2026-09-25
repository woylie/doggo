defmodule Doggo.Components.BottomNavigationTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_bottom_navigation()
  end

  describe "bottom_navigation/1" do
    test "renders navigation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation
          current_value={:appointments}
          label="Main"
        >
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "bottom-navigation"

      a = find_one(nav, "ul > li > a")
      assert attribute(a, "aria-current") == nil
      assert attribute(a, "aria-label") == nil
      assert attribute(a, "href") == "/profile"

      assert text(a, "span.bottom-navigation-icon") == "profile-icon"
      assert text(a, "span:last-child") == "Profile"
    end

    test "renders label as aria-label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation
          current_value={:appointments}
          label="Main"
        >
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Main"
    end

    test "renders labels as aria-label with hide_labels" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation
          current_value={:appointments}
          hide_labels
          label="Main"
        >
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert [span] = Floki.children(a)
      assert attribute(span, "class") == "bottom-navigation-icon"
      assert attribute(a, "aria-label") == "Profile"
    end

    test "marks current item with single value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:show} label="Main">
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root > ul > li > a", "aria-current") == "page"
    end

    test "marks current item with list of values" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:show} label="Main">
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root > ul > li > a", "aria-current") == "page"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation
          current_value={:show}
          label="Main"
          data-test="hello"
        >
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end
end
