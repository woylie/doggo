defmodule Doggo.ComponentsTest do
  use ExUnit.Case
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS
  alias Phoenix.LiveView.LiveStream

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
    menu_item()
    menu_item_checkbox()
    menu_item_radio_group()
    modal()
    navbar()
    navbar_items()
    page_header()
    property_list()
    radio_group()
    skeleton()
    split_pane()
    stack()
    steps()
    switch()
    tab_navigation()
    table()
    tabs()
    tag()
    toggle_button()
    toolbar()
    tooltip()
    tree()
    tree_item()

    button_link(
      name: :button_link_with_disabled_class,
      disabled_class: "disabled"
    )

    stack(name: :stack_with_recursive_class, recursive_class: "recursive")
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

  describe "menu_item/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item on_click={JS.push("hello")}>
          Action
        </TestComponents.menu_item>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "phx-click")
      assert attribute(button, "role") == "menuitem"
      assert text(button) == "Action"
    end
  end

  describe "menu_item_checkbox/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_checkbox on_click={JS.push("hello")}>
          Action
        </TestComponents.menu_item_checkbox>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "phx-click")
      assert attribute(div, "role") == "menuitemcheckbox"
      assert attribute(div, "aria-checked") == "false"
      assert text(div) == "Action"
    end

    test "checked" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_checkbox on_click={JS.push("hello")} checked>
          Action
        </TestComponents.menu_item_checkbox>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "aria-checked") == "true"
    end
  end

  describe "menu_item_radio_group/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_radio_group label="Theme">
          <:item on_click={JS.push("dark")}>Dark</:item>
        </TestComponents.menu_item_radio_group>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "group"
      assert attribute(ul, "aria-label") == "Theme"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"

      assert div = find_one(li, "div")
      assert attribute(div, "role") == "menuitemradio"
      assert attribute(div, "phx-click")
      assert attribute(div, "aria-checked") == "false"
      assert text(div) == "Dark"
    end

    test "checked" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_radio_group label="Theme">
          <:item on_click={JS.push("dark")} checked>Dark</:item>
        </TestComponents.menu_item_radio_group>
        """)

      div = find_one(html, "ul:root > li > div")
      assert attribute(div, "aria-checked") == "true"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_radio_group label="Dog actions" data-test="hello">
          <:item on_click={JS.push("dark")}>Dark</:item>
        </TestComponents.menu_item_radio_group>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "modal/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" on_cancel={JS.push("cancel")}>
          <:title>Edit dog</:title>
          dog-form
          <:footer>paw</:footer>
        </TestComponents.modal>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "id") == "pet-modal"
      assert attribute(dialog, "class") == "modal"
      assert attribute(dialog, "aria-modal") == "false"
      assert attribute(dialog, "open") == nil
      assert attribute(dialog, "phx-mounted") == nil

      a = find_one(html, ":root > div > section > header > button.modal-close")
      assert attribute(a, "aria-label") == "Close"
      assert text(a, "span") == "close"

      h2 = find_one(html, ":root > div > section > header > h2")
      assert text(h2) == "Edit dog"

      assert text(html, "section > .modal-content") == "dog-form"
      assert text(html, "section > footer") == "paw"
    end

    test "not dismissable" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal
          id="pet-modal"
          on_cancel={JS.push("cancel")}
          dismissable={false}
        >
          <:title>Edit dog</:title>
          dog-form
          <:footer>paw</:footer>
        </TestComponents.modal>
        """)

      assert Floki.find(html, ".modal-close") == []
    end

    test "opened" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" open>
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.modal>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "aria-modal") == "true"
      assert attribute(dialog, "open") == "open"
    end

    test "with close slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" open>
          <:title>Edit dog</:title>
          dog-form
          <:close>X</:close>
        </TestComponents.modal>
        """)

      assert text(html, "button.modal-close") == "X"
    end

    test "with close label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" close_label="Cancel" open>
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.modal>
        """)

      assert attribute(html, "button.modal-close", "aria-label") == "Cancel"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" data-test="hello">
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.modal>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "navbar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar label="Main">content</TestComponents.navbar>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "navbar"
      assert attribute(nav, "aria-label") == "Main"
      assert text(nav) == "content"
      assert Floki.find(html, ".navbar-brand") == []
    end

    test "with brand" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar label="Main">
          <:brand>Doggo</:brand>
          content
        </TestComponents.navbar>
        """)

      div = find_one(html, ":root > .navbar-brand")
      assert text(div) == "Doggo"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar label="Main" data-test="hello">
          content
        </TestComponents.navbar>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "navbar_items/1" do
    test "default" do
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

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.navbar_items>
          <:item class="is-highlighted">item</:item>
        </TestComponents.navbar_items>
        """)

      assert attribute(html, ":root > li", "class") == "is-highlighted"
    end

    test "with global attribute" do
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

  describe "page_header/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets" />
        """)

      assert attribute(html, "header:root", "class") == "page-header"
      assert text(html, ":root > .page-header-title > h1") == "Pets"
      assert Floki.find(html, ".page-header-title > h2") == []
      assert Floki.find(html, ".page-header-actions") == []
    end

    test "with subtitle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets" subtitle="All of them" />
        """)

      assert text(html, ":root > .page-header-title > p") == "All of them"
    end

    test "with action" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets">
          <:action>Create</:action>
        </TestComponents.page_header>
        """)

      assert text(html, ":root > .page-header-actions") == "Create"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "property_list/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.property_list>
          <:prop label="Name">George</:prop>
        </TestComponents.property_list>
        """)

      assert attribute(html, "dl", "class") == "property-list"
      assert text(html, "dl > div > dt") == "Name"
      assert text(html, "dl > div > dd") == "George"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.property_list data-test="value">
          <:prop label="Name">George</:prop>
        </TestComponents.property_list>
        """)

      assert attribute(html, "dl", "data-test") == "value"
    end
  end

  describe "radio_group/1" do
    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog_name"
          label="Favorite Dog"
          value="german_shepherd"
          options={[
            {"Labrador Retriever", "labrador"},
            {"German Shepherd", "german_shepherd"}
          ]}
        />
        """)

      assert attribute(html, "div:root", "role") == "radiogroup"
      assert attribute(html, ":root", "id") == "favorite_dog_rg"
      assert attribute(html, ":root", "aria-label") == "Favorite Dog"

      input = find_one(html, "label:first-child input")
      assert attribute(input, "type") == "radio"
      assert attribute(input, "id") == "favorite_dog_rg_labrador"
      assert attribute(input, "name") == "favorite_dog_name"
      assert attribute(input, "checked") == nil
      assert text(html, "label:first-child") == "Labrador Retriever"

      input = find_one(html, "label:last-child input")
      assert attribute(input, "type") == "radio"
      assert attribute(input, "id") == "favorite_dog_rg_german_shepherd"
      assert attribute(input, "name") == "favorite_dog_name"
      assert attribute(input, "checked") == "checked"
      assert text(html, "label:last-child") == "German Shepherd"
    end

    test "with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          labelledby="rg-label"
          options={[{"Labrador Retriever", "labrador"}]}
        />
        """)

      assert attribute(html, ":root", "aria-labelledby") == "rg-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          label="Favorite Dog"
          labelledby="rg-label"
          options={[{"Labrador Retriever", "labrador"}]}
        />
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          options={[{"Labrador Retriever", "labrador"}]}
        />
        """)
      end
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          labelledby="rg-label"
          options={[{"Labrador Retriever", "labrador"}]}
          data-test="hi"
        />
        """)

      assert attribute(html, ":root", "data-test") == "hi"
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

  describe "split_pane/1" do
    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          label="Sidebar"
          orientation="horizontal"
          default_size={200}
          min_size={100}
          max_size={400}
        >
          <:primary>One</:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)

      assert attribute(html, "div:root", "class") == "split-pane"
      assert attribute(html, ":root", "id") == "sidebar-splitter"
      assert attribute(html, ":root", "data-orientation") == "horizontal"

      div = find_one(html, ":root > :first-child")
      assert attribute(div, "id") == "sidebar-splitter-primary"
      assert text(div) == "One"

      div = find_one(html, ":root > :last-child")
      assert attribute(div, "id") == "sidebar-splitter-secondary"
      assert text(div) == "Two"

      div = find_one(html, ":root > div[role='separator']")
      assert attribute(div, "aria-label") == "Sidebar"
      assert attribute(div, "aria-labelledby") == nil
      assert attribute(div, "aria-controls") == "sidebar-splitter-primary"
      assert attribute(div, "aria-valuenow") == "200"
      assert attribute(div, "aria-valuemin") == "100"
      assert attribute(div, "aria-valuemax") == "400"
    end

    test "with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          labelledby="sidebar-heading"
          orientation="horizontal"
          default_size={200}
        >
          <:primary>
            <h2 id="sidebar-heading">Sidebar</h2>
          </:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)

      div = find_one(html, "[role='separator']")
      assert attribute(div, "aria-label") == nil
      assert attribute(div, "aria-labelledby") == "sidebar-heading"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          label="Sidebar"
          labelledby="sidebar-heading"
          orientation="horizontal"
          default_size={200}
        >
          <:primary>One</:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          orientation="horizontal"
          default_size={200}
        >
          <:primary>One</:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)
      end
    end
  end

  describe "stack/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack>Hello</TestComponents.stack>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "stack"
      assert text(div) == "Hello"
    end

    test "recursive" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack recursive>Hello</TestComponents.stack>
        """)

      assert attribute(html, "div", "class") == "stack is-recursive"
    end

    test "recursive with custom recursive class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack_with_recursive_class recursive>
          Hello
        </TestComponents.stack_with_recursive_class>
        """)

      assert attribute(html, "div", "class") == "stack recursive"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack data-what="ever">Hello</TestComponents.stack>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "steps/1" do
    test "first step without links" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0}>
          <:step>Customer Information</:step>
          <:step>Plan</:step>
          <:step>Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Form steps"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span") == "Customer Information"
      assert text(li2, "span") == "Plan"
      assert text(li3, "span") == "Add-ons"

      assert attribute(li1, "class") == "is-current"
      assert attribute(li2, "class") == "is-upcoming"
      assert attribute(li3, "class") == "is-upcoming"

      assert attribute(li1, "aria-current") == "step"
      assert attribute(li2, "aria-current") == nil
      assert attribute(li3, "aria-current") == nil
    end

    test "first step with links" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0}>
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Form steps"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span") == "Customer Information"
      assert text(li2, "a") == "Plan"
      assert text(li3, "a") == "Add-ons"

      assert attribute(li2, "a", "phx-click") == "to-plan"
      assert attribute(li3, "a", "phx-click") == "to-add-ons"
    end

    test "with completed step" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={1}>
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Form steps"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span.is-visually-hidden") == "Completed:"
      assert text(li1, "a") == "Customer Information"
      assert text(li2, "span") == "Plan"
      assert text(li3, "a") == "Add-ons"

      assert attribute(li1, "a", "phx-click") == "to-customer-info"
      assert attribute(li3, "a", "phx-click") == "to-add-ons"

      assert attribute(li1, "class") == "is-completed"
      assert attribute(li2, "class") == "is-current"
      assert attribute(li3, "class") == "is-upcoming"
    end

    test "with completed step and linear" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={1} linear>
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Form steps"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span.is-visually-hidden") == "Completed:"
      assert text(li1, "a") == "Customer Information"
      assert text(li2, "span") == "Plan"
      assert text(li3, "span") == "Add-ons"

      assert attribute(li1, "a", "phx-click") == "to-customer-info"
    end

    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0} label="Hops">
          <:step>Customer Information</:step>
        </TestComponents.steps>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Hops"
    end

    test "with completed label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={1} completed_label="Done: ">
          <:step>Customer Information</:step>
          <:step>Plan</:step>
        </TestComponents.steps>
        """)

      ol = find_one(html, "nav:root ol")
      assert [li1, _] = Floki.children(ol)
      assert text(li1, "span.is-visually-hidden") == "Done:"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0} data-test="hello">
          <:step>Plan</:step>
        </TestComponents.steps>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end

  describe "switch/1" do
    test "default checked" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.switch label="Subscribe" checked />
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "switch"
      assert attribute(button, "aria-checked") == "true"

      assert text(button, "span.switch-label") == "Subscribe"

      control = find_one(button, "span.switch-control")
      assert Floki.children(control) == [{"span", [], []}]

      span = find_one(button, "span.switch-state > span")
      assert attribute(span, "class") == "switch-state-on"
      assert attribute(span, "aria-hidden") == "true"
      assert text(span) == "On"
    end

    test "default unchecked" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.switch label="Subscribe" />
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "aria-checked") == "false"

      span = find_one(button, "span.switch-state > span")
      assert attribute(span, "class") == "switch-state-off"
      assert text(span) == "Off"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.switch label="Subscribe" data-test="hello" />
        """)

      assert attribute(html, "button:root", "data-test") == "hello"
    end
  end

  describe "tab_navigation/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation current_value={:appointments}>
          <:item href="/profile" value={:show}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "tab-navigation"
      assert attribute(nav, "aria-label") == "Tabs"

      a = find_one(nav, "ul > li > a")
      assert attribute(a, "aria-current") == nil
      assert attribute(a, "href") == "/profile"
    end

    test "with single value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation current_value={:show}>
          <:item href="/profile" value={:show}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert attribute(a, "aria-current") == "page"
    end

    test "with multiple values" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation current_value={:show}>
          <:item href="/profile" value={[:show, :edit]}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert attribute(a, "aria-current") == "page"
    end

    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation current_value={:appointments} label="Tabby">
          <:item href="/profile" value={:show}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Tabby"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tab_navigation current_value={:show} data-test="hello">
          <:item value={[:show, :edit]}>Profile</:item>
        </TestComponents.tab_navigation>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end

  describe "table/1" do
    test "default" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:action :let={p} label="Link">link-to-<%= p.id %></:action>
        </TestComponents.table>
        """)

      assert attribute(html, "div:root", "class") == "table-container"
      assert attribute(html, ":root > table", "id") == "pets"
      assert text(html, "table > thead > tr > th:first-child") == "Name"
      assert text(html, "table > thead > tr > th:last-child") == "Link"
      assert attribute(html, "table > tbody", "id") == "pets-tbody"
      assert text(html, "tbody > tr > td:first-child") == "George"
      assert text(html, "tbody > tr > td:last-child") == "link-to-1"
    end

    test "with caption" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} caption="some text">
          <:col :let={p} label="Name"><%= p.name %></:col>
        </TestComponents.table>
        """)

      assert text(html, "table > caption") == "some text"
    end

    test "with col attrs on column" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name" col_attrs={[style: "width: 20%;"]}>
            <%= p.name %>
          </:col>
          <:action :let={p} label="Link">link-to-<%= p.id %></:action>
        </TestComponents.table>
        """)

      assert attribute(html, "table > colgroup > col:first-child", "style") ==
               "width: 20%;"
    end

    test "with col attrs on action" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:action :let={p} label="Link" col_attrs={[style: "width: 20%;"]}>
            link-to-<%= p.id %>
          </:action>
        </TestComponents.table>
        """)

      assert attribute(html, "table > colgroup > col:last-child", "style") ==
               "width: 20%;"
    end

    test "with foot" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:foot>some foot</:foot>
        </TestComponents.table>
        """)

      assert text(html, "table > tfoot") == "some foot"
    end

    test "with row id" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_id={&"row-#{&1.id}"}>
          <:col :let={p} label="Name"><%= p.name %></:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody > tr", "id") == "row-1"
    end

    test "with row click" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_click={&"clicked-#{&1.id}"}>
          <:col :let={p} label="Name"><%= p.name %></:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody td", "phx-click") == "clicked-1"
    end

    test "with row item" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_item={&Map.put(&1, :name, "G")}>
          <:col :let={p} label="Name"><%= p.name %></:col>
        </TestComponents.table>
        """)

      assert text(html, "tbody td") == "G"
    end

    test "with stream" do
      assigns = %{
        pets:
          LiveStream.new(
            :pets,
            0,
            [%{id: 1, name: "George"}, %{id: 2, name: "Mary"}],
            []
          )
      }

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={{id, p}} label="Name"><%= id %> <%= p.name %></:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody", "phx-update") == "stream"
      assert attribute(html, "tbody tr:first-child", "id") == "pets-1"
      assert attribute(html, "tbody tr:last-child", "id") == "pets-2"
      assert text(html, "tbody tr:first-child td") == "pets-1 George"
      assert text(html, "tbody tr:last-child td") == "pets-2 Mary"
    end
  end

  describe "tabs/1" do
    test "default" do
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
      assert attribute(button, "tabindex") == nil
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

    test "with labelledby" do
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

    test "with global attribute" do
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

  describe "toolbar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar label="Actions for dog">
          buttons
        </TestComponents.toolbar>
        """)

      assert attribute(html, "div:root", "role") == "toolbar"
      assert attribute(html, ":root", "aria-label") == "Actions for dog"
      assert attribute(html, ":root", "aria-labelledby") == nil
      assert text(html, ":root") == "buttons"
    end

    test "with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar labelledby="toolbar-heading"></TestComponents.toolbar>
        """)

      assert attribute(html, ":root", "aria-label") == nil
      assert attribute(html, ":root", "aria-labelledby") == "toolbar-heading"
    end

    test "with controls" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar label="Actions for dog" controls="dog-panel">
        </TestComponents.toolbar>
        """)

      assert attribute(html, ":root", "aria-controls") == "dog-panel"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.toolbar label="Dog actions" labelledby="dog-toolbar-label">
        </TestComponents.toolbar>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.toolbar></TestComponents.toolbar>
        """)
      end
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar label="Actions for dog" data-test="hello">
        </TestComponents.toolbar>
        """)

      assert attribute(html, "div", "data-test") == "hello"
    end
  end

  describe "tooltip/1" do
    test "with text" do
      id = "text-details"
      expected_id = id <> "-tooltip"
      assigns = %{id: id}

      html =
        parse_heex(~H"""
        <TestComponents.tooltip id={@id}>
          some text
          <:tooltip>some details</:tooltip>
        </TestComponents.tooltip>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "data-aria-tooltip") == "data-aria-tooltip"
      assert attribute(span, "aria-describedby") == expected_id

      inner_span = find_one(html, "span > span")
      assert attribute(inner_span, "tabindex") == "0"
      assert text(inner_span) == "some text"

      tooltip = find_one(html, "span > div[role='tooltip']")
      assert attribute(tooltip, "id") == expected_id
      assert text(tooltip) == "some details"
    end

    test "with link" do
      id = "text-details"
      expected_id = id <> "-tooltip"

      assigns = %{id: id}

      html =
        parse_heex(~H"""
        <TestComponents.tooltip id={@id} contains_link>
          some link
          <:tooltip>some details</:tooltip>
        </TestComponents.tooltip>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "data-aria-tooltip") == "data-aria-tooltip"
      assert attribute(span, "aria-describedby") == expected_id

      inner_span = find_one(html, "span:root > span")
      assert attribute(inner_span, "tabindex") == nil
      assert text(inner_span) == "some link"

      tooltip = find_one(html, "span:root > div[role='tooltip']")
      assert attribute(tooltip, "id") == expected_id
      assert text(tooltip) == "some details"
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
