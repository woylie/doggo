defmodule Doggo.Components.AlertTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_alert()
  end

  describe "alert/1" do
    test "renders alert" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert">message</TestComponents.alert>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "id") == "some-alert"
      assert attribute(div, "role") == "alert"
      assert attribute(div, "class") == "alert"
      assert attribute(div, "data-level") == "info"
      assert attribute(div, "aria-labelledby") == nil

      assert text(html, ":root > .alert-body > .alert-message") == "message"

      assert Floki.find(html, ".alert-icon") == []
      assert Floki.find(html, ".alert-title") == []
      assert Floki.find(html, "button") == []
    end

    test "renders level as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" level="warning">
          message
        </TestComponents.alert>
        """)

      assert attribute(html, ":root", "class") == "alert"
      assert attribute(html, ":root", "data-level") == "warning"
    end

    test "labels alert with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" level="danger" title="Title">
          message
        </TestComponents.alert>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "some-alert-title"

      div = find_one(html, ":root > .alert-body > .alert-title")
      assert attribute(div, "id") == "some-alert-title"
      assert text(div) == "Title"
    end

    test "renders icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert">
          message
          <:icon>some-icon</:icon>
        </TestComponents.alert>
        """)

      assert text(html, ":root > .alert-icon") == "some-icon"
    end

    test "renders close button with on_close" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" on_close="close-alert">
          message
        </TestComponents.alert>
        """)

      assert attribute(html, ":root", "phx-click") == nil

      button = find_one(html, ":root > button.alert-close")
      assert attribute(button, "type") == "button"
      assert attribute(button, "phx-click") == "close-alert"
      assert attribute(button, "aria-label") == "Close"
      assert text(button, "span") == "Close"
    end

    test "raises for invalid on_close" do
      assigns = %{on_close: %{event: "close"}}

      assert_raise ArgumentError, ~r/invalid on_close value for \.alert/, fn ->
        parse_heex(~H"""
        <TestComponents.alert id="dog-alert" on_close={@on_close}>
          message
        </TestComponents.alert>
        """)
      end
    end

    test "renders close label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" on_close="close-alert" close_label="klose">
          message
        </TestComponents.alert>
        """)

      button = find_one(html, ":root > button")
      assert attribute(button, "aria-label") == "klose"
      assert text(button, "span") == "klose"
    end

    test "renders close slot in close button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert
          id="some-alert"
          on_close="close-alert"
          close_label="Dismiss"
        >
          message
          <:close>X</:close>
        </TestComponents.alert>
        """)

      button = find_one(html, ":root > button")
      assert attribute(button, "aria-label") == "Dismiss"
      assert text(button) == "X"
    end

    test "renders actions" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" on_close="close-alert">
          message
          <:action><button>Sign in</button></:action>
        </TestComponents.alert>
        """)

      actions = find_one(html, ":root > .alert-body > .alert-actions")
      assert text(actions, "button") == "Sign in"
      assert Floki.find(html, ".alert-actions .alert-close") == []
    end

    test "omits actions without action slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert">message</TestComponents.alert>
        """)

      assert Floki.find(html, ".alert-actions") == []
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" data-test="hi">
          message
        </TestComponents.alert>
        """)

      assert attribute(html, ":root", "data-test") == "hi"
    end
  end
end
