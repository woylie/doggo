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
    box()
    breadcrumb()
    button()
    button_link()
    cluster()
    disclosure_button()
    fab()
    tag()
    skeleton()
    toggle_button()
    tree()
    tree_item()

    button_link(
      name: :button_link_with_disabled_class,
      disabled_class: "disabled"
    )
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

  describe "box/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          Content
        </TestComponents.box>
        """)

      section = find_one(html, "section:root")
      assert attribute(section, "class") == "box"
      assert text(section) == "Content"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:title>Profile</:title>
        </TestComponents.box>
        """)

      assert text(html, "section:root > header > h2") == "Profile"
    end

    test "with banner" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:banner>Banner</:banner>
        </TestComponents.box>
        """)

      assert text(html, "section:root > header > div.box-banner") == "Banner"
    end

    test "with action" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:action>Action</:action>
        </TestComponents.box>
        """)

      assert text(html, "section:root > header > div.box-actions") == "Action"
    end

    test "with footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:footer>Doggo</:footer>
        </TestComponents.box>
        """)

      assert text(html, "section:root > footer") == "Doggo"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box data-test="hello"></TestComponents.box>
        """)

      assert attribute(html, "section:root", "data-test") == "hello"
    end
  end

  describe "breadcrumb/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.breadcrumb>
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

    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.breadcrumb label="Brotkrumen">
          <:item patch="/categories">Categories</:item>
        </TestComponents.breadcrumb>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Brotkrumen"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.breadcrumb data-test="hello">
          <:item patch="/categories">Categories</:item>
        </TestComponents.breadcrumb>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end

  describe "button/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button>Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"

      assert attribute(button, "class") ==
               "button is-primary is-normal is-solid"

      assert text(button) == "Confirm"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button disabled>Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "with type" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button type="submit">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "type") == "submit"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button variant="danger">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") ==
               "button is-danger is-normal is-solid"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button size="large">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") ==
               "button is-primary is-large is-solid"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button shape="pill">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") ==
               "button is-primary is-normal is-solid is-pill"
    end

    test "with fill" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button fill="outline">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") ==
               "button is-primary is-normal is-outline"
    end
  end

  describe "button_link/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link patch="/confirm">
          Confirm
        </TestComponents.button_link>
        """)

      a = find_one(html, "a:root")
      assert attribute(a, "role") == nil
      assert attribute(a, "class") == "button is-primary is-normal is-solid"
      assert attribute(a, "href") == "/confirm"
      assert text(a) == "Confirm"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled>Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "button is-primary is-normal is-solid is-disabled"
    end

    test "disabled with custom disabled class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link_with_disabled_class disabled>
          Confirm
        </TestComponents.button_link_with_disabled_class>
        """)

      assert attribute(html, "a:root", "class") ==
               "button is-primary is-normal is-solid disabled"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link variant="info">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "button is-info is-normal is-solid"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link size="small">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "button is-primary is-small is-solid"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link shape="pill">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "button is-primary is-normal is-solid is-pill"
    end

    test "with fill" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link fill="text">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "button is-primary is-normal is-text"
    end

    test "with global attribute" do
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

  describe "disclosure_button/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.disclosure_button controls="data-table">
          Data Table
        </TestComponents.disclosure_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-expanded") == "false"
      assert attribute(button, "aria-controls") == "data-table"
      assert text(button) == "Data Table"
    end
  end

  describe "fab/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fab label="Add toy">add-icon</TestComponents.fab>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "class") == "fab is-primary is-normal is-circle"
      assert attribute(button, "aria-label") == "Add toy"
      assert text(button) == "add-icon"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fab label="Add toy" disabled>add-icon</TestComponents.fab>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fab label="Add toy" variant="success">
          add-icon
        </TestComponents.fab>
        """)

      assert attribute(html, "button:root", "class") ==
               "fab is-success is-normal is-circle"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fab label="Add toy" phx-click="add">
          add-icon
        </TestComponents.fab>
        """)

      assert attribute(html, "button:root", "phx-click") == "add"
    end
  end

  describe "skeleton/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.skeleton type="circle" />
        """)

      assert attribute(html, "div:root", "class") == "skeleton is-circle"
    end

    test "with text block" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.skeleton type="text-block" />
        """)

      assert attribute(html, "div:root", "class") == "skeleton is-text-block"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.skeleton type="square" data-test="hello" />
        """)

      assert attribute(html, "div:root", "data-test") == "hello"
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

  describe "toggle_button/1" do
    test "with pressed false" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")}>
          Mute
        </TestComponents.toggle_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-pressed") == "false"
      assert attribute(button, "phx-click")
      assert text(button) == "Mute"
    end

    test "with pressed true" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")} pressed>
          Mute
        </TestComponents.toggle_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-pressed") == "true"
      assert attribute(button, "phx-click")
      assert text(button) == "Mute"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")} disabled>
          Mute
        </TestComponents.toggle_button>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")} variant="danger">
          Mute
        </TestComponents.toggle_button>
        """)

      assert attribute(html, "button:root", "class") ==
               "button is-danger is-normal is-solid"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button
          on_click={JS.push("toggle-mute")}
          data-test="hello"
        >
          Mute
        </TestComponents.toggle_button>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "tree/1" do
    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree label="Dogs">
          items
        </TestComponents.tree>
        """)

      assert attribute(html, "ul:root", "role") == "tree"
      assert attribute(html, ":root", "aria-label") == "Dogs"
      assert text(html, ":root") == "items"
    end

    test "with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree labelledby="dog-tree-label"></TestComponents.tree>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "dog-tree-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.tree label="Dogs" labelledby="dog-tree-label">
        </TestComponents.tree>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.tree></TestComponents.tree>
        """)
      end
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree labelledby="rg-label" data-test="hi"></TestComponents.tree>
        """)

      assert attribute(html, ":root", "data-test") == "hi"
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
