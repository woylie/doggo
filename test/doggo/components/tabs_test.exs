defmodule Doggo.Components.TabsTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_tabs()
  end

  describe "tabs/1" do
    test "renders tabs" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tabs id="my-tabs" label="My Tabs">
          <:panel label="Panel 1">some text</:panel>
          <:panel label="Panel 2">some other text</:panel>
        </TestComponents.tabs>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "tabs"
      assert attribute(div, "id") == "my-tabs"

      div = find_one(html, ":root > div[role='tablist']")
      assert attribute(div, "aria-label") == "My Tabs"
      assert attribute(div, "aria-labelledby") == nil

      button = find_one(div, "button:first-child")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "tab"
      assert attribute(button, "id") == "my-tabs-tab-1"
      assert attribute(button, "aria-selected") == "true"
      assert attribute(button, "aria-controls") == "my-tabs-panel-1"
      assert attribute(button, "tabindex") == "0"
      assert text(button) == "Panel 1"

      button = find_one(div, "button:last-child")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "tab"
      assert attribute(button, "id") == "my-tabs-tab-2"
      assert attribute(button, "aria-selected") == "false"
      assert attribute(button, "aria-controls") == "my-tabs-panel-2"
      assert attribute(button, "tabindex") == "-1"
      assert text(button) == "Panel 2"

      div = find_one(html, ":root > div#my-tabs-panel-1")
      assert attribute(div, "role") == "tabpanel"
      assert attribute(div, "aria-labelledby") == "my-tabs-tab-1"
      assert attribute(div, "hidden") == nil
      assert text(div) == "some text"

      div = find_one(html, ":root > div#my-tabs-panel-2")
      assert attribute(div, "role") == "tabpanel"
      assert attribute(div, "aria-labelledby") == "my-tabs-tab-2"
      assert attribute(div, "hidden") == "hidden"
      assert text(div) == "some other text"
    end

    test "renders vertical orientation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tabs id="my-tabs" label="My Tabs" orientation="vertical">
          <:panel label="Panel 1">some text</:panel>
          <:panel label="Panel 2">some other text</:panel>
        </TestComponents.tabs>
        """)

      assert attribute(html, "[role='tablist']", "aria-orientation") ==
               "vertical"
    end

    test "puts only selected tab in tab order" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tabs id="my-tabs" label="My Tabs">
          <:panel label="Panel 1">some text</:panel>
          <:panel label="Panel 2">some other text</:panel>
          <:panel label="Panel 3">some more text</:panel>
        </TestComponents.tabs>
        """)

      tabindexes =
        html
        |> Floki.find("button[role='tab']")
        |> Enum.map(&attribute(&1, "tabindex"))

      assert tabindexes == ["0", "-1", "-1"]
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tabs id="my-tabs" labelledby="my-tabs-title">
          <:panel label="Panel 1">some text</:panel>
          <:panel label="Panel 2">some other text</:panel>
        </TestComponents.tabs>
        """)

      div = find_one(html, "div[role='tablist']")
      assert attribute(div, "aria-label") == nil
      assert attribute(div, "aria-labelledby") == "my-tabs-title"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.tabs id="my-tabs" label="My Tabs" labelledby="my-tabs-title">
          <:panel label="Panel 1">some text</:panel>
          <:panel label="Panel 2">some other text</:panel>
        </TestComponents.tabs>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.tabs id="my-tabs">
          <:panel label="Panel 1">some text</:panel>
          <:panel label="Panel 2">some other text</:panel>
        </TestComponents.tabs>
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tabs id="my-tabs" label="My Tabs" data-test="hello">
          <:panel label="Panel 1">some text</:panel>
        </TestComponents.tabs>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
