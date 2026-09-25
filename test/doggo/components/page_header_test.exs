defmodule Doggo.Components.PageHeaderTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_page_header()
  end

  describe "page_header/1" do
    test "renders page header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets" />
        """)

      assert attribute(html, "header:root", "class") == "page-header"
      assert text(html, ":root > hgroup > h1") == "Pets"
      assert Floki.find(html, "hgroup > h2") == []
      assert attribute(html, ":root > hgroup", "class") == nil
      assert Floki.find(html, ".page-header-actions") == []
    end

    test "renders subtitle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets" subtitle="All of them" />
        """)

      assert text(html, ":root > hgroup > p") == "All of them"
    end

    test "renders navigation entry as link" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets">
          <:navigation navigate="/pets">Back to pets</:navigation>
        </TestComponents.page_header>
        """)

      assert text(html, ":root > .page-header-navigation > a") == "Back to pets"

      assert attribute(html, ":root > .page-header-navigation > a", "href") ==
               "/pets"
    end

    test "renders navigation entry without link if it has no target" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets">
          <:navigation>Back to pets</:navigation>
        </TestComponents.page_header>
        """)

      assert Floki.find(html, ".page-header-navigation a") == []
      assert text(html, ":root > .page-header-navigation") == "Back to pets"
    end

    test "renders actions" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets">
          <:action>Create</:action>
        </TestComponents.page_header>
        """)

      assert text(html, ":root > .page-header-actions") == "Create"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
