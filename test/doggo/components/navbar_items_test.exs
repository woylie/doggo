defmodule Doggo.Components.NavbarItemsTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_navbar_items()
  end

  describe "navbar_items/1" do
    test "renders navbar items" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar_items>
          <:item>item</:item>
        </TestComponents.navbar_items>
        """)

      assert attribute(html, "ul:root", "class") == "navbar-items"
      assert text(html, ":root > li") == "item"
    end

    test "renders item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar_items>
          <:item class="is-highlighted">item</:item>
        </TestComponents.navbar_items>
        """)

      assert attribute(html, ":root > li", "class") == "is-highlighted"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar_items data-test="hello">
          <:item>item</:item>
        </TestComponents.navbar_items>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
