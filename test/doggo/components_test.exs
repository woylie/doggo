defmodule Doggo.ComponentsTest do
  use ExUnit.Case
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Phoenix.Component
    import Doggo.Components

    accordion()
    action_bar()
    badge()
    cluster()
    tag()
    tree_item()
  end

  describe "accordion/1" do
    test "with expanded all" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.accordion id="dog-breeds">
          <:section title="Golden Retriever">abc</:section>
          <:section title="Siberian Husky">def</:section>
        </TestComponents.accordion>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "accordion"
      assert attribute(div, "id") == "dog-breeds"

      button = find_one(html, ":root > div > h3 > button#dog-breeds-trigger-1")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-expanded") == "true"
      assert attribute(button, "aria-controls") == "dog-breeds-section-1"
      assert text(button, "span") == "Golden Retriever"

      div = find_one(html, ":root > div > div#dog-breeds-section-1")
      assert attribute(div, "role") == "region"
      assert attribute(div, "aria-labelledby") == "dog-breeds-trigger-1"
      assert attribute(div, "hidden") == nil
      assert text(div) == "abc"

      button = find_one(html, ":root > div > h3 > button#dog-breeds-trigger-2")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-expanded") == "true"
      assert attribute(button, "aria-controls") == "dog-breeds-section-2"
      assert text(button, "span") == "Siberian Husky"

      div = find_one(html, ":root > div > div#dog-breeds-section-2")
      assert attribute(div, "role") == "region"
      assert attribute(div, "aria-labelledby") == "dog-breeds-trigger-2"
      assert attribute(div, "hidden") == nil
      assert text(div) == "def"
    end

    test "with heading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.accordion id="dog-breeds" heading="h4">
          <:section title="Golden Retriever">abc</:section>
        </TestComponents.accordion>
        """)

      assert [_] =
               Floki.find(
                 html,
                 ":root > div > h4 > button#dog-breeds-trigger-1"
               )
    end

    test "with expanded none" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.accordion id="dogs" expanded={:none}>
          <:section title="Golden Retriever">abc</:section>
          <:section title="Siberian Husky">def</:section>
        </TestComponents.accordion>
        """)

      assert attribute(html, "#dogs-trigger-1", "aria-expanded") == "false"
      assert attribute(html, "#dogs-trigger-2", "aria-expanded") == "false"

      assert attribute(html, "#dogs-section-1", "hidden") == "hidden"
      assert attribute(html, "#dogs-section-2", "hidden") == "hidden"
    end

    test "with expanded first" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.accordion id="dogs" expanded={:first}>
          <:section title="Golden Retriever">abc</:section>
          <:section title="Siberian Husky">def</:section>
        </TestComponents.accordion>
        """)

      assert attribute(html, "#dogs-trigger-1", "aria-expanded") == "true"
      assert attribute(html, "#dogs-trigger-2", "aria-expanded") == "false"

      assert attribute(html, "#dogs-section-1", "hidden") == nil
      assert attribute(html, "#dogs-section-2", "hidden") == "hidden"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.accordion id="dog-breeds" data-test="hello">
          <:section title="Golden Retriever"></:section>
        </TestComponents.accordion>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "action_bar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.action_bar>
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </TestComponents.action_bar>
        """)

      assert attribute(html, "div:root", "class") == "action-bar"
      assert attribute(html, ":root", "role") == "toolbar"

      button = find_one(html, ":root > button")
      assert attribute(button, "title") == "Edit"

      assert attribute(button, "phx-click") ==
               "[[\"push\",{\"event\":\"edit\"}]]"

      assert text(button) == "edit-icon"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.action_bar data-what="ever">
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </TestComponents.action_bar>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "badge/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge>value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge is-normal"
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge size="large">value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge is-large"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge variant="secondary">value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge is-normal is-secondary"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge data-what="ever">value</TestComponents.badge>
        """)

      assert attribute(html, "span", "data-what") == "ever"
    end
  end

  describe "cluster/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.cluster>Hello</TestComponents.cluster>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "cluster"
      assert text(div) == "Hello"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.cluster data-what="ever">Hello</TestComponents.cluster>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "tag/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag>value</TestComponents.tag>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "tag is-normal"
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag size="medium">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag is-medium"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag variant="primary">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag is-normal is-primary"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag shape="pill">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag is-normal is-pill"
    end
  end

  describe "tree_item/1" do
    test "without children" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree_item>
          Breeds
        </TestComponents.tree_item>
        """)

      assert attribute(html, "li:root", "role") == "treeitem"
      assert attribute(html, ":root", "aria-expanded") == nil
      assert attribute(html, ":root", "aria-selected") == "false"
      assert text(html, ":root > span") == "Breeds"
      assert Floki.find(html, ":root ul") == []
    end

    test "with children" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree_item>
          Breeds
          <:items>
            <TestComponents.tree_item>Golden Retriever</TestComponents.tree_item>
            <TestComponents.tree_item>Labrador Retriever</TestComponents.tree_item>
          </:items>
        </TestComponents.tree_item>
        """)

      assert attribute(html, "li:root", "role") == "treeitem"
      assert attribute(html, ":root", "aria-expanded") == "false"
      assert attribute(html, ":root", "aria-selected") == "false"
      assert text(html, ":root > span") == "Breeds"

      assert ul = find_one(html, "li:root > ul")
      assert attribute(ul, "role") == "group"

      assert li = find_one(ul, "li:first-child")
      assert attribute(li, "role") == "treeitem"
      assert attribute(li, ":root", "aria-expanded") == nil
      assert attribute(li, ":root", "aria-selected") == "false"
      assert text(li, ":root > span") == "Golden Retriever"
      assert Floki.find(li, ":root ul") == []

      assert li = find_one(ul, "li:last-child")
      assert attribute(li, "role") == "treeitem"
      assert attribute(li, ":root", "aria-expanded") == nil
      assert attribute(li, ":root", "aria-selected") == "false"
      assert text(li, ":root > span") == "Labrador Retriever"
      assert Floki.find(li, ":root ul") == []
    end
  end
end
