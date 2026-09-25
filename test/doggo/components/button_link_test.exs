defmodule Doggo.Components.ButtonLinkTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_button_link()
  end

  describe "button_link/1" do
    test "renders link" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link patch="/confirm">
          Confirm
        </TestComponents.button_link>
        """)

      a = find_one(html, "a:root")
      assert attribute(a, "role") == nil
      assert attribute(a, "class") == "button"
      assert attribute(a, "data-variant") == "primary"
      assert attribute(a, "data-size") == "normal"
      assert attribute(a, "data-fill") == "solid"
      assert attribute(a, "href") == "/confirm"
      assert attribute(a, "role") == nil
      assert attribute(a, "aria-disabled") == nil
      assert attribute(a, "tabindex") == nil
      assert attribute(a, "data-disabled") == nil
      assert text(a) == "Confirm"
    end

    test "renders disabled link" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled>Confirm</TestComponents.button_link>
        """)

      a = find_one(html, "a:root")
      assert attribute(a, "class") == "button"
      assert attribute(a, "role") == "link"
      assert attribute(a, "aria-disabled") == "true"
      assert attribute(a, "tabindex") == "0"
      assert attribute(a, "data-disabled") == nil
      assert attribute(a, "href") == nil
      assert text(a) == "Confirm"
    end

    test "removes href if disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled href="/confirm">
          Confirm
        </TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "href") == nil
    end

    test "removes navigate and patch if disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled navigate="/confirm">
          Confirm
        </TestComponents.button_link>
        """)

      a = find_one(html, "a:root")
      assert attribute(a, "href") == nil
      assert attribute(a, "navigate") == nil
      assert attribute(a, "data-phx-link") == nil

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled patch="/confirm">
          Confirm
        </TestComponents.button_link>
        """)

      a = find_one(html, "a:root")
      assert attribute(a, "href") == nil
      assert attribute(a, "patch") == nil
    end

    test "keeps global attributes if disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled data-test="keep" target="_blank">
          Confirm
        </TestComponents.button_link>
        """)

      a = find_one(html, "a:root")
      assert attribute(a, "data-test") == "keep"
      assert attribute(a, "target") == "_blank"
    end

    test "renders variant as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link variant="info">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-variant") == "info"
    end

    test "renders size as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link size="small">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-size") == "small"
    end

    test "renders shape as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link shape="pill">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-shape") == "pill"
    end

    test "renders fill as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link fill="text">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-fill") == "text"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link data-test="hello">
          Register
        </TestComponents.button_link>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
