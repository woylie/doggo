defmodule Doggo.Components.CalloutTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_callout()
  end

  describe "callout/1" do
    test "renders callout" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.callout id="my-callout">Did you know?</TestComponents.callout>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "callout"
      assert attribute(div, "data-level") == "info"
      assert attribute(div, "id") == "my-callout"
      assert attribute(div, "aria-labelledby") == nil

      assert text(div, "div.callout-body > div.callout-message") ==
               "Did you know?"

      assert Floki.find(div, ".callout-icon") == []
      assert Floki.find(div, ".callout-title") == []
      assert Floki.find(html, ".callout-actions") == []
    end

    test "labels callout with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.callout id="my-callout" title="Did you know?">
          Know what?
        </TestComponents.callout>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "aria-labelledby") == "my-callout-title"

      div = find_one(div, ".callout-body > .callout-title")
      assert attribute(div, "id") == "my-callout-title"
      assert text(div) == "Did you know?"
    end

    test "renders icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.callout id="my-callout">
          <:icon>lightbulb</:icon>
          Did you know?
        </TestComponents.callout>
        """)

      assert text(html, "div:root > .callout-icon") == "lightbulb"
    end

    test "renders actions" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.callout id="callout">
          message
          <:action><button>Do something</button></:action>
        </TestComponents.callout>
        """)

      actions = find_one(html, ":root > .callout-body > .callout-actions")
      assert text(actions, "button") == "Do something"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.callout id="my-callout" data-test="hello">
          Did you know?
        </TestComponents.callout>
        """)

      assert attribute(html, "div:root", "data-test") == "hello"
    end
  end
end
