defmodule Doggo.Components.AlertTest do
  use ExUnit.Case
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
    test "default" do
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

    test "with level" do
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

    test "with title" do
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

    test "with icon" do
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

    test "with on_click" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" on_close="close-alert">
          message
        </TestComponents.alert>
        """)

      assert attribute(html, "phx-click") == "close-alert"

      button = find_one(html, ":root > button")
      assert attribute(button, "phx-click") == "close-alert"
      assert text(button) == "close"
    end

    test "with close label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert id="some-alert" on_close="close-alert" close_label="klose">
          message
        </TestComponents.alert>
        """)

      assert text(html, ":root > button") == "klose"
    end

    test "with global attribute" do
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
