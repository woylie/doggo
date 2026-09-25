defmodule Doggo.Components.BreadcrumbTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_breadcrumb()
  end

  describe "breadcrumb/1" do
    test "renders breadcrumb" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.breadcrumb label="Breadcrumb">
          <:item patch="/categories">Categories</:item>
          <:item patch="/categories/1">Reviews</:item>
          <:item patch="/categories/1/articles/1">The Movie</:item>
        </TestComponents.breadcrumb>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "breadcrumb"
      assert attribute(nav, "aria-label") == "Breadcrumb"

      ol = find_one(html, "nav:root > ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert attribute(li1, "a", "href") == "/categories"
      assert attribute(li2, "a", "href") == "/categories/1"
      assert attribute(li3, "a", "href") == "/categories/1/articles/1"

      assert attribute(li1, "a", "aria-current") == nil
      assert attribute(li2, "a", "aria-current") == nil
      assert attribute(li3, "a", "aria-current") == "page"

      assert text(li1, "a") == "Categories"
      assert text(li2, "a") == "Reviews"
      assert text(li3, "a") == "The Movie"
    end

    test "renders label as aria-label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.breadcrumb label="Brotkrumen">
          <:item patch="/categories">Categories</:item>
        </TestComponents.breadcrumb>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Brotkrumen"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.breadcrumb label="Breadcrumb" data-test="hello">
          <:item patch="/categories">Categories</:item>
        </TestComponents.breadcrumb>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end
end
