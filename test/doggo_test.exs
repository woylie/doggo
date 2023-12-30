defmodule DoggoTest do
  use ExUnit.Case
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS
  alias Phoenix.LiveView.LiveStream

  describe "action_bar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.action_bar>
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </Doggo.action_bar>
        """)

      assert attribute(html, "div", "class") == "action-bar"

      a = find_one(html, "div > a")
      assert attribute(a, "title") == "Edit"
      assert attribute(a, "phx-click") == "[[\"push\",{\"event\":\"edit\"}]]"

      assert text(a) == "edit-icon"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.action_bar class="is-narrow">
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </Doggo.action_bar>
        """)

      assert attribute(html, "div", "class") == "action-bar is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.action_bar class={["is-narrow", "is-crisp"]}>
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </Doggo.action_bar>
        """)

      assert attribute(html, "div", "class") == "action-bar is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.action_bar data-what="ever">
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </Doggo.action_bar>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "alert/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.alert id="some-alert">message</Doggo.alert>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "id") == "some-alert"
      assert attribute(div, "role") == "alert"
      assert attribute(div, "class") == "is-info"
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
        <Doggo.alert id="some-alert" level={:warning}>message</Doggo.alert>
        """)

      assert attribute(html, ":root", "class") == "is-warning"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.alert id="some-alert" level={:danger} title="Title">
          message
        </Doggo.alert>
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
        <Doggo.alert id="some-alert">
          message
          <:icon>some-icon</:icon>
        </Doggo.alert>
        """)

      assert text(html, ":root > .alert-icon") == "some-icon"
    end

    test "with on_click" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.alert id="some-alert" on_close="close-alert">
          message
        </Doggo.alert>
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
        <Doggo.alert id="some-alert" on_close="close-alert" close_label="klose">
          message
        </Doggo.alert>
        """)

      assert text(html, ":root > button") == "klose"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.alert id="some-alert" class="is-hip">message</Doggo.alert>
        """)

      assert attribute(html, ":root", "class") == "is-info is-hip"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.alert id="some-alert" class={["is-hip", "is-brisk"]}>
          message
        </Doggo.alert>
        """)

      assert attribute(html, ":root", "class") == "is-info is-hip is-brisk"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.alert id="some-alert" data-test="hi">message</Doggo.alert>
        """)

      assert attribute(html, ":root", "data-test") == "hi"
    end
  end

  describe "app_bar/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<Doggo.app_bar></Doggo.app_bar>")
      header = find_one(html, "header")
      assert attribute(header, "class") == "app-bar"
      assert Floki.children(header) == []
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar title="Some Title"></Doggo.app_bar>
        """)

      assert text(html, "header h1") == "Some Title"
    end

    test "with navigation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar>
          <:navigation label="Back" on_click="back">back-icon</:navigation>
        </Doggo.app_bar>
        """)

      a = find_one(html, "header div.app-bar-navigation a")
      assert attribute(a, "title") == "Back"
      assert attribute(a, "phx-click") == "back"
      assert text(a) == "back-icon"
    end

    test "with action" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar>
          <:action label="Menu" on_click="open-menu">menu-icon</:action>
        </Doggo.app_bar>
        """)

      a = find_one(html, "header div.app-bar-actions a")
      assert attribute(a, "title") == "Menu"
      assert attribute(a, "phx-click") == "open-menu"
      assert text(a) == "menu-icon"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar class="is-narrow"></Doggo.app_bar>
        """)

      assert attribute(html, "header", "class") == "app-bar is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar class={["is-narrow", "is-crisp"]}></Doggo.app_bar>
        """)

      assert attribute(html, "header", "class") == "app-bar is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar data-what="ever"></Doggo.app_bar>
        """)

      assert attribute(html, "header", "data-what") == "ever"
    end
  end

  describe "avatar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" />
        """)

      assert attribute(html, "div:root", "class") == "avatar"

      img = find_one(html, ":root > img")
      assert attribute(img, "src") == "avatar.png"
      assert attribute(img, "alt") == ""
      assert attribute(img, "loading") == "lazy"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" size={:large} />
        """)

      assert attribute(html, "div:root", "class") == "avatar is-large"
    end

    test "with circle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" circle />
        """)

      assert attribute(html, "div:root", "class") == "avatar is-circle"
    end

    test "with loading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" loading="eager" />
        """)

      assert attribute(html, ":root > img", "loading") == "eager"
    end

    test "with alt" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" alt="Avatar" />
        """)

      assert attribute(html, ":root > img", "alt") == "Avatar"
    end

    test "with text placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src={nil} placeholder="A" />
        """)

      assert Floki.find(html, "img") == []
      assert text(html, ":root > span") == "A"
    end

    test "without image or placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src={nil} />
        """)

      assert html == []
    end

    test "with image placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src={nil} placeholder={{:src, "placeholder.png"}} />
        """)

      assert attribute(html, ":root > img", "src") == "placeholder.png"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" class="has-border" />
        """)

      assert attribute(html, ":root", "class") == "avatar has-border"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" class={["has-border", "has-shadow"]} />
        """)

      assert attribute(html, ":root", "class") == "avatar has-border has-shadow"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "badge/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.badge>value</Doggo.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge "
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.badge size={:large}>value</Doggo.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge is-large"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.badge variant={:secondary}>value</Doggo.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge is-secondary"
    end
  end

  describe "bottom_navigation/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:appointments}>
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "bottom-navigation"

      a = find_one(nav, "ul > li > a")
      assert attribute(a, "aria-current") == nil
      assert attribute(a, "aria-label") == "Profile"
      assert attribute(a, "href") == "/profile"

      assert text(a, "span.icon") == "profile-icon"
      assert text(a, "span:last-child") == "Profile"
    end

    test "with aria label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:appointments} label="Main">
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Main"
    end

    test "with hide_labels" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:appointments} hide_labels>
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert [span] = Floki.children(a)
      assert attribute(span, "class") == "icon"
    end

    test "with single value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:show}>
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      assert attribute(html, "nav:root > ul > li > a", "aria-current") == "page"
    end

    test "with multiple values" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:show}>
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      assert attribute(html, "nav:root > ul > li > a", "aria-current") == "page"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:show} class="is-narrow">
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "class") ==
               "bottom-navigation is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:show} class={["is-narrow", "is-crisp"]}>
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "class") ==
               "bottom-navigation is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.bottom_navigation current_value={:show} data-test="hello">
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </Doggo.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end

  describe "box/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box>
          Content
        </Doggo.box>
        """)

      section = find_one(html, "section:root")
      assert attribute(section, "class") == "box"
      assert text(section) == "Content"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box>
          <:title>Profile</:title>
        </Doggo.box>
        """)

      assert text(html, "section:root > header > h2") == "Profile"
    end

    test "with banner" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box>
          <:banner>Banner</:banner>
        </Doggo.box>
        """)

      assert text(html, "section:root > header > div.box-banner") == "Banner"
    end

    test "with action" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box>
          <:action>Action</:action>
        </Doggo.box>
        """)

      assert text(html, "section:root > header > div.box-actions") == "Action"
    end

    test "with footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box>
          <:footer>Doggo</:footer>
        </Doggo.box>
        """)

      assert text(html, "section:root > footer") == "Doggo"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box class="is-wide"></Doggo.box>
        """)

      assert attribute(html, "section:root", "class") == "box is-wide"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box class={["is-wide", "is-crisp"]}></Doggo.box>
        """)

      assert attribute(html, "section:root", "class") == "box is-wide is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.box data-test="hello"></Doggo.box>
        """)

      assert attribute(html, "section:root", "data-test") == "hello"
    end
  end

  describe "breadcrumb/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.breadcrumb>
          <:item patch="/categories">Categories</:item>
          <:item patch="/categories/1">Reviews</:item>
          <:item patch="/categories/1/articles/1">The Movie</:item>
        </Doggo.breadcrumb>
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
        <Doggo.breadcrumb label="Brotkrumen">
          <:item patch="/categories">Categories</:item>
        </Doggo.breadcrumb>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Brotkrumen"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.breadcrumb class="is-fancy">
          <:item patch="/categories">Categories</:item>
        </Doggo.breadcrumb>
        """)

      assert attribute(html, "nav:root", "class") == "breadcrumb is-fancy"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.breadcrumb class={["is-fancy", "is-dandy"]}>
          <:item patch="/categories">Categories</:item>
        </Doggo.breadcrumb>
        """)

      assert attribute(html, "nav:root", "class") ==
               "breadcrumb is-fancy is-dandy"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.breadcrumb data-test="hello">
          <:item patch="/categories">Categories</:item>
        </Doggo.breadcrumb>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end

  describe "button/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button>Confirm</Doggo.button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "class") == "is-primary is-solid"
      assert text(button) == "Confirm"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button disabled>Confirm</Doggo.button>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "with type" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button type="submit">Confirm</Doggo.button>
        """)

      assert attribute(html, "button:root", "type") == "submit"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button variant={:danger}>Confirm</Doggo.button>
        """)

      assert attribute(html, "button:root", "class") == "is-danger is-solid"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button size={:large}>Confirm</Doggo.button>
        """)

      assert attribute(html, "button:root", "class") ==
               "is-primary is-large is-solid"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button shape={:pill}>Confirm</Doggo.button>
        """)

      assert attribute(html, "button:root", "class") ==
               "is-primary is-pill is-solid"
    end

    test "with fill" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button fill={:outline}>Confirm</Doggo.button>
        """)

      assert attribute(html, "button:root", "class") == "is-primary is-outline"
    end
  end

  describe "button_link/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button_link patch="/confirm">Confirm</Doggo.button_link>
        """)

      a = find_one(html, "a:root")
      assert attribute(a, "role") == "button"
      assert attribute(a, "class") == "is-primary is-solid"
      assert attribute(a, "href") == "/confirm"
      assert text(a) == "Confirm"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button_link disabled>Confirm</Doggo.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "is-primary is-solid is-disabled"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button_link variant={:info}>Confirm</Doggo.button_link>
        """)

      assert attribute(html, "a:root", "class") == "is-info is-solid"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button_link size={:small}>Confirm</Doggo.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "is-primary is-small is-solid"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button_link shape={:pill}>Confirm</Doggo.button_link>
        """)

      assert attribute(html, "a:root", "class") ==
               "is-primary is-pill is-solid"
    end

    test "with fill" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.button_link fill={:text}>Confirm</Doggo.button_link>
        """)

      assert attribute(html, "a:root", "class") == "is-primary is-text"
    end
  end

  describe "callout/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.callout id="my-callout">Did you know?</Doggo.callout>
        """)

      aside = find_one(html, "aside:root")
      assert attribute(aside, "class") == "callout is-info"
      assert attribute(aside, "id") == "my-callout"
      assert attribute(aside, "aria-labelledby") == nil

      assert text(aside, "div.callout-body > div.callout-message") ==
               "Did you know?"

      assert Floki.find(aside, ".callout-icon") == []
      assert Floki.find(aside, ".callout-title") == []
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.callout id="my-callout" title="Did you know?">
          Know what?
        </Doggo.callout>
        """)

      aside = find_one(html, "aside:root")
      assert attribute(aside, "aria-labelledby") == "my-callout-title"

      div = find_one(aside, ".callout-body > .callout-title")
      assert attribute(div, "id") == "my-callout-title"
      assert text(div) == "Did you know?"
    end

    test "with icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.callout id="my-callout">
          <:icon>lightbulb</:icon>
          Did you know?
        </Doggo.callout>
        """)

      assert text(html, "aside:root > .callout-icon") == "lightbulb"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.callout id="my-callout" class="is-cute">
          Did you know?
        </Doggo.callout>
        """)

      assert attribute(html, "aside:root", "class") == "callout is-info is-cute"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.callout id="my-callout" class={["is-cute", "is-petite"]}>
          Did you know?
        </Doggo.callout>
        """)

      assert attribute(html, "aside:root", "class") ==
               "callout is-info is-cute is-petite"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.callout id="my-callout" data-test="hello">
          Did you know?
        </Doggo.callout>
        """)

      assert attribute(html, "aside:root", "data-test") == "hello"
    end
  end

  describe "card/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<Doggo.card></Doggo.card>")
      article = find_one(html, "article")
      assert attribute(article, "class") == "card"
      assert Floki.children(article) == []
    end

    test "with figure" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:image>Doggo</:image>
        </Doggo.card>
        """)

      assert text(html, "article > figure") == "Doggo"
    end

    test "with header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:header>Doggo</:header>
        </Doggo.card>
        """)

      assert text(html, "article > header") == "Doggo"
    end

    test "with main" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:main>Doggo</:main>
        </Doggo.card>
        """)

      assert text(html, "article > main") == "Doggo"
    end

    test "with footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:footer>Doggo</:footer>
        </Doggo.card>
        """)

      assert text(html, "article > footer") == "Doggo"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card class="is-narrow"></Doggo.card>
        """)

      assert attribute(html, "article", "class") == "card is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card class={["is-narrow", "is-crisp"]}></Doggo.card>
        """)

      assert attribute(html, "article", "class") == "card is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card data-what="ever"></Doggo.card>
        """)

      assert attribute(html, "article", "data-what") == "ever"
    end
  end

  describe "cluster/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.cluster>Hello</Doggo.cluster>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "cluster"
      assert text(div) == "Hello"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.cluster class="is-narrow">Hello</Doggo.cluster>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "cluster is-narrow"
      assert text(div) == "Hello"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.cluster class={["is-narrow", "is-crisp"]}>Hello</Doggo.cluster>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "cluster is-narrow is-crisp"
      assert text(div) == "Hello"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.cluster data-what="ever">Hello</Doggo.cluster>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "date/1" do
    test "with Date" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~D[2023-12-27]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~N[2023-12-27T18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date
          value={nil}
          formatter={& &1}
          title_formatter={& &1}
          timezone="Asia/Tokyo"
        />
        """)

      assert html == []
    end

    test "with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date
          value={~N[2023-12-27 18:30:21]}
          formatter={&"#{&1.year}/#{&1.month}/#{&1.day}"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023/12/27"
    end

    test "with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date
          value={~N[2023-12-27 18:30:21]}
          title_formatter={&"#{&1.year}/#{&1.month}/#{&1.day}"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "title") == "2023/12/27"
      assert text(time) == "2023-12-27"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-28"
      assert text(time) == "2023-12-28"
    end
  end

  describe "datetime/1" do
    test "with DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27 18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "2023-12-27 18:30:21"
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime
          value={nil}
          formatter={& &1}
          title_formatter={& &1}
          precision={:minute}
          timezone="Asia/Tokyo"
        />
        """)

      assert html == []
    end

    test "with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime
          value={~N[2023-12-27 18:30:21]}
          formatter={&"#{&1.month}/#{&1.year} ~#{&1.hour}h"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "12/2023 ~18h"
    end

    test "with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime
          value={~N[2023-12-27 18:30:21]}
          title_formatter={&"#{&1.month}/#{&1.year} ~#{&1.hour}h"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "title") == "12/2023 ~18h"
    end

    test "with DateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107074Z"
      assert text(time) == "2023-12-27 18:30:21.107074Z"
    end

    test "with DateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107Z"
      assert text(time) == "2023-12-27 18:30:21.107Z"
    end

    test "with DateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~U[2023-12-27T18:30:21.107074Z]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "with DateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~U[2023-12-27T18:30:21.107074Z]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00Z"
      assert text(time) == "2023-12-27 18:30:00Z"
    end

    test "with NaiveDateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:microsecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107074"
      assert text(time) == "2023-12-27 18:30:21.107074"
    end

    test "with NaiveDateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:millisecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107"
      assert text(time) == "2023-12-27 18:30:21.107"
    end

    test "with NaiveDateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "2023-12-27 18:30:21"
    end

    test "with NaiveDateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00"
      assert text(time) == "2023-12-27 18:30:00"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-28T03:30:21+09:00"
      assert text(time) == "2023-12-28 03:30:21+09:00 JST Asia/Tokyo"
    end
  end

  describe "drawer/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<Doggo.drawer></Doggo.drawer>")
      aside = find_one(html, "aside")
      assert attribute(aside, "class") == "drawer"
      assert Floki.children(aside) == []
    end

    test "with brand" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:brand>Doggo</:brand>
        </Doggo.drawer>
        """)

      assert text(html, "aside > div.drawer-brand") == "Doggo"
    end

    test "with top slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:top>Doggo</:top>
        </Doggo.drawer>
        """)

      assert text(html, "aside > div.drawer-top") == "Doggo"
    end

    test "with bottom slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:bottom>Doggo</:bottom>
        </Doggo.drawer>
        """)

      assert text(html, "aside > div.drawer-bottom") == "Doggo"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer class="is-narrow"></Doggo.drawer>
        """)

      assert attribute(html, "aside", "class") == "drawer is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer class={["is-narrow", "is-crisp"]}></Doggo.drawer>
        """)

      assert attribute(html, "aside", "class") == "drawer is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer data-what="ever"></Doggo.drawer>
        """)

      assert attribute(html, "aside", "data-what") == "ever"
    end
  end

  describe "drawer_nav/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nav id="main-nav" label="Main">
          <:item>item</:item>
        </Doggo.drawer_nav>
        """)

      div = find_one(html, "nav:root")
      assert attribute(div, "id") == "main-nav"
      assert attribute(div, "aria-label") == "Main"
      assert Floki.find(html, ".drawer-nav-title") == []
      assert text(html, ":root > ul > li") == "item"
    end

    test "with current page" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nav id="main-nav" label="Main">
          <:item current_page>item</:item>
        </Doggo.drawer_nav>
        """)

      assert attribute(html, ":root > ul > li", "aria-current") == "page"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nav id="main-nav" label="Main">
          <:title>some title</:title>
          <:item>item</:item>
        </Doggo.drawer_nav>
        """)

      assert text(html, ":root > div.drawer-nav-title") == "some title"
    end

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nav id="main-nav" label="Main">
          <:item class="is-rad">item</:item>
        </Doggo.drawer_nav>
        """)

      assert attribute(html, "li", "class") == "is-rad"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nav id="main-nav" label="Main" class="is-rad">
          <:item>item</:item>
        </Doggo.drawer_nav>
        """)

      assert attribute(html, ":root", "class") == "is-rad"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nav id="main-nav" label="Main" class={["hey", "ho"]}>
          <:item>item</:item>
        </Doggo.drawer_nav>
        """)

      assert attribute(html, ":root", "class") == "hey ho"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nav id="main-nav" label="Main" data-test="hello">
          <:item>item</:item>
        </Doggo.drawer_nav>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "drawer_nested_nav/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nested_nav id="nested">
          <:item>item</:item>
        </Doggo.drawer_nested_nav>
        """)

      assert attribute(html, "ul:root", "id") == "nested"
      li = find_one(html, "ul:root li")
      assert attribute(li, "aria-labelledby") == nil
      assert text(li) == "item"
      assert Floki.find(html, ".drawer-nav-title") == []
    end

    test "with current page" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nested_nav id="nested">
          <:item current_page>item</:item>
        </Doggo.drawer_nested_nav>
        """)

      assert attribute(html, "ul:root > li", "aria-current") == "page"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nested_nav id="nested">
          <:title>some title</:title>
          <:item>item</:item>
        </Doggo.drawer_nested_nav>
        """)

      div = find_one(html, "div.drawer-nav-title")
      assert attribute(div, "id") == "nested-title"
      assert text(div) == "some title"
      assert attribute(html, "ul:root", "aria-labelledby") == "nested-title"
    end

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_nested_nav id="nested">
          <:item class="is-rad">item</:item>
        </Doggo.drawer_nested_nav>
        """)

      assert attribute(html, "li", "class") == "is-rad"
    end
  end

  describe "drawer_section/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_section id="my-drawer">
          <:item>item</:item>
        </Doggo.drawer_section>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "drawer-section"
      assert attribute(div, "id") == "my-drawer"
      assert attribute(div, "aria-labelledby") == nil
      assert Floki.find(html, ".drawer-section-title") == []
      assert text(html, ":root > div.drawer-item") == "item"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_section id="my-drawer">
          <:title>some title</:title>
          <:item>item</:item>
        </Doggo.drawer_section>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "aria-labelledby") == "my-drawer-title"

      div = find_one(html, "div > .drawer-section-title")
      assert attribute(div, "id") == "my-drawer-title"
      assert text(div) == "some title"
    end

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_section id="my-drawer">
          <:item class="is-rad">item</:item>
        </Doggo.drawer_section>
        """)

      assert attribute(html, ":root > div", "class") == "drawer-item is-rad"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_section id="my-drawer" class="is-narrow">
          <:item>item</:item>
        </Doggo.drawer_section>
        """)

      assert attribute(html, ":root", "class") == "drawer-section is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_section id="my-drawer" class={["is-narrow", "is-crisp"]}>
          <:item>item</:item>
        </Doggo.drawer_section>
        """)

      assert attribute(html, ":root", "class") ==
               "drawer-section is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer_section id="my-drawer" data-test="hello">
          <:item>item</:item>
        </Doggo.drawer_section>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "fab/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fab label="Add toy">add-icon</Doggo.fab>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "class") == "fab is-primary is-circle"
      assert attribute(button, "aria-label") == "Add toy"
      assert text(button) == "add-icon"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fab label="Add toy" disabled>add-icon</Doggo.fab>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fab label="Add toy" variant={:success}>add-icon</Doggo.fab>
        """)

      assert attribute(html, "button:root", "class") ==
               "fab is-success is-circle"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fab label="Add toy" size={:large}>add-icon</Doggo.fab>
        """)

      assert attribute(html, "button:root", "class") ==
               "fab is-primary is-large is-circle"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fab label="Add toy" shape={:pill}>add-icon</Doggo.fab>
        """)

      assert attribute(html, "button:root", "class") ==
               "fab is-primary is-pill"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fab label="Add toy" phx-click="add">add-icon</Doggo.fab>
        """)

      assert attribute(html, "button:root", "phx-click") == "add"
    end
  end

  describe "field_description/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_description for="some-input">text</Doggo.field_description>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "field-description"
      assert attribute(div, "id") == "some-input_description"
    end
  end

  describe "field_errors/1" do
    test "without errors" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_errors for="some-input" errors={[]} />
        """)

      assert html == []
    end

    test "with errors" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_errors for="some-input" errors={["some error"]} />
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "class") == "field-errors"
      assert attribute(ul, "id") == "some-input_errors"
      assert text(html, "ul > li") == "some error"
    end
  end

  describe "fallback/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fallback value="dog" />
        """)

      assert html == ["dog"]
    end

    test "with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fallback value="dog" formatter={&String.upcase/1} />
        """)

      assert html == ["DOG"]
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fallback value={nil} />
        """)

      assert html == [{"span", [{"aria-label", "not set"}], ["-"]}]
    end

    test "with empty string and formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fallback value="" formatter={&String.upcase/1} />
        """)

      assert html == [{"span", [{"aria-label", "not set"}], ["-"]}]
    end

    test "with placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fallback value={[]} placeholder="n/a" />
        """)

      assert html == [{"span", [{"aria-label", "not set"}], ["n/a"]}]
    end

    test "with accessibility text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.fallback value={[]} accessibility_text="not available" />
        """)

      assert html == [{"span", [{"aria-label", "not available"}], ["-"]}]
    end
  end

  describe "field_group/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group>fields</Doggo.field_group>
        """)

      div = find_one(html, "div")
      assert attribute(div, "class") == "field-group"
      assert text(div) == "fields"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group class="is-narrow">fields</Doggo.field_group>
        """)

      assert attribute(html, "div", "class") == "field-group is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group class={["is-narrow", "is-crisp"]}>
          fields
        </Doggo.field_group>
        """)

      assert attribute(html, "div", "class") == "field-group is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group data-what="ever">fields</Doggo.field_group>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "flash_group/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.flash_group flash={%{}} />
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "flash-group"
      assert attribute(div, "id") == "flash-group"

      div = find_one(html, ":root > #flash-group-client-error")
      assert attribute(div, "class") == "is-danger"
      assert attribute(div, "hidden") == "hidden"

      div = find_one(html, ":root > #flash-group-server-error")
      assert attribute(div, "class") == "is-danger"
      assert attribute(div, "hidden") == "hidden"
    end

    test "with id" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.flash_group id="flashes" flash={%{}} />
        """)

      assert attribute(html, ":root", "id") == "flashes"
      find_one(html, ":root > #flashes-client-error")
      find_one(html, ":root > #flashes-server-error")
    end

    test "with info flash" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.flash_group flash={%{"info" => "info-flash"}} />
        """)

      div = find_one(html, "div:root > #flash-group-flash-info")
      assert text(div, ".alert-title") == "Success"
      assert text(div, ".alert-message") == "info-flash"
    end

    test "with error flash" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.flash_group flash={%{"error" => "error-flash"}} />
        """)

      div = find_one(html, "div:root > #flash-group-flash-error")
      assert text(div, ".alert-title") == "Error"
      assert text(div, ".alert-message") == "error-flash"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.flash_group flash={%{}} class="is-green" />
        """)

      assert attribute(html, ":root", "class") == "flash-group is-green"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.flash_group flash={%{}} class={["is-green", "is-wide"]} />
        """)

      assert attribute(html, ":root", "class") == "flash-group is-green is-wide"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.flash_group flash={%{}} data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "frame/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.frame>image</Doggo.frame>
        """)

      assert attribute(html, "div", "class") == "frame "
      assert text(html, "div") == "image"
    end

    test "with ratio" do
      ratios = [
        {1, 1},
        {3, 2},
        {2, 3},
        {4, 3},
        {3, 4},
        {5, 4},
        {4, 5},
        {16, 9},
        {9, 16}
      ]

      for {w, h} = ratio <- ratios do
        assigns = %{ratio: ratio}

        html =
          parse_heex(~H"""
          <Doggo.frame ratio={@ratio}>image</Doggo.frame>
          """)

        assert attribute(html, "div", "class") == "frame is-#{w}-by-#{h}"
      end
    end

    test "with circle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.frame circle>image</Doggo.frame>
        """)

      assert attribute(html, "div", "class") == "frame is-circle"
    end
  end

  describe "icon/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon>some-icon</Doggo.icon>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      assert text(span) == "some-icon"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon size={:small}>some-icon</Doggo.icon>
        """)

      assert attribute(html, "span:root", "class") == "icon is-small"
    end

    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon label="some-label">some-icon</Doggo.icon>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "span:root", "aria-label") == "some-label"
      assert Floki.find(html, "span > span") == []
    end

    test "with label left" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon label="some-label" label_placement={:left}>
          some-icon
        </Doggo.icon>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-left"
      assert attribute(span, "span:root", "aria-label") == nil
      assert text(html, "span > span") == "some-label"
    end

    test "with label right" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon label="some-label" label_placement={:right}>
          some-icon
        </Doggo.icon>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-right"
      assert attribute(span, "span:root", "aria-label") == nil
      assert text(html, "span > span") == "some-label"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon class="is-rad">some-icon</Doggo.icon>
        """)

      assert attribute(html, ":root", "class") == "icon is-rad"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon class={["is-rad", "is-boud"]}>some-icon</Doggo.icon>
        """)

      assert attribute(html, ":root", "class") == "icon is-rad is-boud"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon data-test="hello">some-icon</Doggo.icon>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "icon_sprite/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      svg = find_one(span, "svg")
      assert attribute(svg, "aria-hidden") == "true"
      assert attribute(svg, "use", "href") == "/assets/icons/sprite.svg#edit"
    end

    test "with sprite URL" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite sprite_url="/images/icons.svg" name="edit" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      svg = find_one(span, "svg")
      assert attribute(svg, "aria-hidden") == "true"
      assert attribute(svg, "use", "href") == "/images/icons.svg#edit"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" size={:small} />
        """)

      assert attribute(html, "span:root", "class") == "icon is-small"
    end

    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" label="some-label" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "span:root", "aria-label") == "some-label"
      assert Floki.find(html, "span > span") == []
    end

    test "with label left" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" label="some-label" label_placement={:left} />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-left"
      assert attribute(span, "span:root", "aria-label") == nil
      assert text(html, "span > span") == "some-label"
    end

    test "with label right" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" label="some-label" label_placement={:right} />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-right"
      assert attribute(span, "span:root", "aria-label") == nil
      assert text(html, "span > span") == "some-label"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" class="is-rad" />
        """)

      assert attribute(html, ":root", "class") == "icon is-rad"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" class={["is-rad", "is-boud"]} />
        """)

      assert attribute(html, ":root", "class") == "icon is-rad is-boud"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "image/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" />
        """)

      figure = find_one(html, "figure:root")
      assert attribute(figure, "class") == "image"

      img = find_one(html, ":root > .frame > img")
      assert attribute(img, "src") == "image.png"
      assert attribute(img, "alt") == "some text"
      assert attribute(img, "loading") == "lazy"
      assert Floki.find(html, "caption") == []
    end

    test "with width and height" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" width={300} height={200} />
        """)

      img = find_one(html, ":root > .frame > img")
      assert attribute(img, "width") == "300"
      assert attribute(img, "height") == "200"
    end

    test "with loading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" loading="eager" />
        """)

      assert attribute(html, "img", "loading") == "eager"
    end

    test "with ratio" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" ratio={{3, 2}} />
        """)

      assert attribute(html, ".frame", "class") == "frame is-3-by-2"
    end

    test "with caption" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text">
          <:caption>some caption</:caption>
        </Doggo.image>
        """)

      assert text(html, ":root > figcaption") == "some caption"
    end

    test "with srcset as string" do
      srcset = "images/image-1x.jpg 1x, images/image-2x.jpg 2x"
      assigns = %{srcset: srcset}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" srcset={@srcset} />
        """)

      assert attribute(html, "img", "srcset") == srcset
    end

    test "with srcset as map" do
      srcset_map = %{
        "1x" => "images/image-1x.jpg",
        "2x" => "images/image-2x.jpg"
      }

      srcset_str = "images/image-1x.jpg 1x, images/image-2x.jpg 2x"
      assigns = %{srcset: srcset_map}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" srcset={@srcset} />
        """)

      assert attribute(html, "img", "srcset") == srcset_str
    end

    test "with sizes" do
      sizes = "(max-width: 30em) 20em"
      assigns = %{sizes: sizes}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" sizes={@sizes} />
        """)

      assert attribute(html, "img", "sizes") == sizes
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" class="has-border" />
        """)

      assert attribute(html, ":root", "class") == "image has-border"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image
          src="image.png"
          alt="some text"
          class={["has-border", "has-shadow"]}
        />
        """)

      assert attribute(html, ":root", "class") == "image has-border has-shadow"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.image src="image.png" alt="some text" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "input/1" do
    test "with text input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:age]} label="Age" />
        </.form>
        """)

      assert attribute(html, ".field", "phx-feedback-for") == "age"

      input = find_one(html, "input")
      assert attribute(input, "id") == "age"
      assert attribute(input, "name") == "age"
      assert attribute(input, "type") == "text"
      assert attribute(input, "aria-describedby") == nil

      assert attribute(html, "label", "for") == "age"
      assert text(html, "label") == "Age"
    end

    test "with text input and description" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:age]} label="Age">
            <:description>How old?</:description>
          </Doggo.input>
        </.form>
        """)

      assert text(html, ".field-description") == "How old?"
      assert attribute(html, ".field-description", "id") == "age_description"
      assert attribute(html, "input", "aria-describedby") == "age_description"
    end

    test "with checkbox" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:subscribe]} label="Subscribe" type="checkbox">
            <:description>Please do.</:description>
          </Doggo.input>
        </.form>
        """)

      assert attribute(html, "label", "class") == "checkbox"
      assert attribute(html, "input[type='hidden']", "value") == "false"

      assert text(html, ".field-description") == "Please do."

      assert attribute(html, ".field-description", "id") ==
               "subscribe_description"

      assert attribute(html, "input[type='checkbox']", "aria-describedby") ==
               "subscribe_description"

      assert attribute(html, "input[type='checkbox']", "value") == "true"
    end

    test "with checkbox and checked value" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={@form[:subscribe]}
            label="Subscribe"
            type="checkbox"
            checked_value="yes"
          >
            <:description>Please do.</:description>
          </Doggo.input>
        </.form>
        """)

      assert attribute(html, "input[type='checkbox']", "value") == "yes"
    end

    test "with checkbox group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={@form[:animals]}
            label="Animals"
            type="checkbox-group"
            options={[{"Dog", "dog"}, "cat", "rabbit_id", :elk]}
            value={["dog", "elk"]}
          >
            <:description>Which animals?</:description>
          </Doggo.input>
        </.form>
        """)

      assert text(html, "fieldset > legend") == "Animals"
      assert attribute(html, "input[type='hidden']", "name") == "animals[]"
      assert attribute(html, "input[type='hidden']", "value") == ""

      input = find_one(html, "input[id='animals_dog']")
      assert attribute(input, "value") == "dog"

      input = find_one(html, "input[id='animals_cat']")
      assert attribute(input, "value") == "cat"
    end

    test "with radio group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={@form[:animals]}
            label="Animals"
            type="radio-group"
            options={[{"Dog", "dog"}, "cat", "rabbit_id", :elk]}
          >
            <:description>Which animals?</:description>
          </Doggo.input>
        </.form>
        """)

      assert text(html, "fieldset > legend") == "Animals"

      input = find_one(html, "input[id='animals_dog']")
      assert attribute(input, "value") == "dog"

      input = find_one(html, "input[id='animals_cat']")
      assert attribute(input, "value") == "cat"
    end

    test "with switch off" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:subscribe]} label="Subscribe" type="switch">
            <:description>Subscribe?</:description>
          </Doggo.input>
        </.form>
        """)

      assert text(html, ".switch-state-off") == "Off"
    end

    test "with switch on" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:subscribe]} label="Subscribe" type="switch" checked>
            <:description>Subscribe?</:description>
          </Doggo.input>
        </.form>
        """)

      assert text(html, ".switch-state-on") == "On"
    end

    test "with select" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={@form[:animals]}
            label="Animals"
            type="select"
            options={[{"Dog", "dog"}, {"Cat", "cat"}]}
          >
            <:description>Which animals?</:description>
          </Doggo.input>
        </.form>
        """)

      assert attribute(html, "option:first-child", "value") == "dog"
      assert attribute(html, "option:last-child", "value") == "cat"
    end

    test "with multiple select" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={@form[:animals]}
            label="Animals"
            type="select"
            options={[{"Dog", "dog"}, {"Cat", "cat"}]}
            multiple
          >
            <:description>Which animals?</:description>
          </Doggo.input>
        </.form>
        """)

      assert attribute(html, "select", "multiple") == "multiple"
    end

    test "with textarea" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:bio]} label="Bio" type="textarea">
            <:description>Tell us more about you.</:description>
          </Doggo.input>
        </.form>
        """)

      textarea = find_one(html, "textarea")
      assert attribute(textarea, "id") == "bio"
      assert attribute(textarea, "name") == "bio"
      assert attribute(textarea, "aria-describedby") == "bio_description"

      assert attribute(html, "label", "for") == "bio"
      assert text(html, "label") == "Bio"
    end

    test "with hidden input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:sentiment]} type="hidden" value="jaja" />
        </.form>
        """)

      assert attribute(html, "input", "type") == "hidden"
      assert attribute(html, "input", "name") == "sentiment"
      assert attribute(html, "input", "value") == "jaja"
    end

    test "with hidden input and list value" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:sentiment]} type="hidden" value={["ja", "ne"]} />
        </.form>
        """)

      assert attribute(html, "input:first-child", "type") == "hidden"
      assert attribute(html, "input:last-child", "type") == "hidden"
      assert attribute(html, "input:first-child", "name") == "sentiment[]"
      assert attribute(html, "input:last-child", "name") == "sentiment[]"
      assert attribute(html, "input:first-child", "value") == "ja"
      assert attribute(html, "input:last-child", "value") == "ne"
    end

    test "with add-ons" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:addons]} type="text">
            <:addon_left>left</:addon_left>
            <:addon_right>right</:addon_right>
          </Doggo.input>
        </.form>
        """)

      assert text(html, ".input-wrapper > .input-addon-left") == "left"
      assert text(html, ".input-wrapper > .input-addon-right") == "right"
    end

    test "with datalist" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={@form[:species]}
            type="text"
            options={["option_a", {"Option B", "option_b"}]}
          />
        </.form>
        """)

      assert attribute(html, "input", "list") == "species_datalist"
      assert attribute(html, "datalist", "id") == "species_datalist"

      assert attribute(html, "datalist > option:first-child", "value") ==
               "option_a"

      assert attribute(html, "datalist > option:last-child", "value") ==
               "option_b"

      assert text(html, "datalist > option:first-child") == "option_a"
      assert text(html, "datalist > option:last-child") == "Option B"
    end

    test "with errors" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:species]} type="text" errors={["wrong"]} />
        </.form>
        """)

      assert attribute(html, "input", "aria-describedby") == "species_errors"
      assert attribute(html, "ul", "id") == "species_errors"
      assert attribute(html, "ul", "class") == "field-errors"
      assert text(html, ".field-errors > li") == "wrong"
    end

    test "with errors and description" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:species]} type="text" errors={["wrong"]}>
            <:description>What are you?</:description>
          </Doggo.input>
        </.form>
        """)

      assert attribute(html, "input", "aria-describedby") ==
               "species_errors species_description"

      assert attribute(html, "ul", "id") == "species_errors"
      assert attribute(html, "ul", "class") == "field-errors"
      assert text(html, ".field-errors > li") == "wrong"

      assert text(html, ".field-description") == "What are you?"

      assert attribute(html, ".field-description", "id") ==
               "species_description"
    end

    test "converts datetime to date string for date input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={@form[:when]}
            type="date"
            value={~U[1900-01-01T12:00:00Z]}
          />
        </.form>
        """)

      assert attribute(html, "input", "value") == "1900-01-01"
    end

    test "converts datetime string to date string for date input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:when]} type="date" value="1900-01-01T12:00:00Z" />
        </.form>
        """)

      assert attribute(html, "input", "value") == "1900-01-01"
    end

    test "removes other invalid date values" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={@form[:when]} type="date" value="1900-01" />
        </.form>
        """)

      assert attribute(html, "input", "value") == ""
    end

    test "inserts gettext variables in errors without gettext module" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={
            %{@form[:what] | errors: [{"weird %{animal}", [animal: "dog"]}]}
          } />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "weird dog"
    end

    test "translates errors with gettext" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={%{@form[:what] | errors: [{"weird dog", []}]}}
            gettext={Doggo.Gettext}
          />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "chien bizarre"
    end

    test "translates errors with numbers with gettext" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input
            field={
              %{
                @form[:what]
                | errors: [
                    {"only %{count} dog(s) allowed", [count: 5]}
                  ]
              }
            }
            gettext={Doggo.Gettext}
          />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "seulement 5 chiens autorisés"
    end
  end

  describe "label/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.label for="some-input">text</Doggo.label>
        """)

      label = find_one(html, "label")
      assert attribute(label, "class") == ""
      assert attribute(label, "for") == "some-input"
      assert text(label) == "text"
      assert Floki.find(html, ".label-required") == []
    end

    test "with required mark" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.label required>text</Doggo.label>
        """)

      mark = find_one(html, "label > abbr.label-required")
      assert attribute(mark, "title") == "required"

      # inputs with `required` attribute are already announced as required
      assert attribute(mark, "aria-hidden") == "true"
    end

    test "with required mark and custom text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.label required_title="necessary" required>text</Doggo.label>
        """)

      assert attribute(html, "label > abbr.label-required", "title") ==
               "necessary"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.label class="is-crooked" visually_hidden>text</Doggo.label>
        """)

      assert attribute(html, ":root", "class") ==
               "is-visually-hidden is-crooked"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.label class={["is-crooked", "is-groovy"]} visually_hidden>
          text
        </Doggo.label>
        """)

      assert attribute(html, ":root", "class") ==
               "is-visually-hidden is-crooked is-groovy"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.label data-test="hello">text</Doggo.label>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "modal/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.modal id="pet-modal" on_cancel={JS.push("cancel")}>
          <:title>Edit dog</:title>
          dog-form
          <:footer>paw</:footer>
        </Doggo.modal>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "id") == "pet-modal"
      assert attribute(dialog, "class") == "modal"
      assert attribute(dialog, "aria-modal") == "false"
      assert attribute(dialog, "open") == nil
      assert attribute(dialog, "phx-mounted") == nil

      a = find_one(html, ":root > div > article > header > a.modal-close")
      assert attribute(a, "aria-label") == "Close"
      assert text(a, "span") == "close"

      h2 = find_one(html, ":root > div > article > header > h2")
      assert text(h2) == "Edit dog"

      assert text(html, "article > .modal-content") == "dog-form"
      assert text(html, "article > footer") == "paw"
    end

    test "opened" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.modal id="pet-modal" open>
          <:title>Edit dog</:title>
          dog-form
        </Doggo.modal>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "aria-modal") == "true"
      assert attribute(dialog, "open") == "open"
    end

    test "with close slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.modal id="pet-modal" open>
          <:title>Edit dog</:title>
          dog-form
          <:close>X</:close>
        </Doggo.modal>
        """)

      assert text(html, "a.modal-close") == "X"
    end

    test "with close label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.modal id="pet-modal" close_label="Cancel" open>
          <:title>Edit dog</:title>
          dog-form
        </Doggo.modal>
        """)

      assert attribute(html, "a.modal-close", "aria-label") == "Cancel"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.modal id="pet-modal" class="is-narrow">
          <:title>Edit dog</:title>
          dog-form
        </Doggo.modal>
        """)

      assert attribute(html, ":root", "class") == "modal is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.modal id="pet-modal" class={["is-narrow", "is-dark"]}>
          <:title>Edit dog</:title>
          dog-form
        </Doggo.modal>
        """)

      assert attribute(html, ":root", "class") == "modal is-narrow is-dark"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.modal id="pet-modal" data-test="hello">
          <:title>Edit dog</:title>
          dog-form
        </Doggo.modal>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "navbar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar label="Main">content</Doggo.navbar>
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
        <Doggo.navbar label="Main">
          <:brand>Doggo</:brand>
          content
        </Doggo.navbar>
        """)

      div = find_one(html, ":root > .navbar-brand")
      assert text(div) == "Doggo"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar label="Main" class="is-narrow">content</Doggo.navbar>
        """)

      assert attribute(html, ":root", "class") == "navbar is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar label="Main" class={["is-narrow", "is-dark"]}>
          content
        </Doggo.navbar>
        """)

      assert attribute(html, ":root", "class") == "navbar is-narrow is-dark"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar label="Main" data-test="hello">content</Doggo.navbar>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "navbar_item/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar_items>
          <:item>item</:item>
        </Doggo.navbar_items>
        """)

      assert attribute(html, "ul:root", "class") == "navbar-items"
      assert text(html, ":root > li") == "item"
    end

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar_items>
          <:item class="is-highlighted">item</:item>
        </Doggo.navbar_items>
        """)

      assert attribute(html, ":root > li", "class") == "is-highlighted"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar_items class="is-highlighted">
          <:item>item</:item>
        </Doggo.navbar_items>
        """)

      assert attribute(html, ":root", "class") == "navbar-items is-highlighted"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar_items class={["is-cute", "is-dark"]}>
          <:item>item</:item>
        </Doggo.navbar_items>
        """)

      assert attribute(html, ":root", "class") == "navbar-items is-cute is-dark"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.navbar_items data-test="hello">
          <:item>item</:item>
        </Doggo.navbar_items>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "page_header/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.page_header title="Pets" />
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
        <Doggo.page_header title="Pets" subtitle="All of them" />
        """)

      assert text(html, ":root > .page-header-title > h2") == "All of them"
    end

    test "with action" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.page_header title="Pets">
          <:action>Create</:action>
        </Doggo.page_header>
        """)

      assert text(html, ":root > .page-header-actions") == "Create"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.page_header title="Pets" class="is-small" />
        """)

      assert attribute(html, ":root", "class") == "page-header is-small"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.page_header title="Pets" class={["is-narrow", "is-crisp"]} />
        """)

      assert attribute(html, ":root", "class") ==
               "page-header is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.page_header title="Pets" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "property_list/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.property_list>
          <:prop label="Name">George</:prop>
        </Doggo.property_list>
        """)

      assert attribute(html, "dl", "class") == "property-list"
      assert text(html, "dl > div > dt") == "Name"
      assert text(html, "dl > div > dd") == "George"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.property_list class="is-narrow">
          <:prop label="Name">George</:prop>
        </Doggo.property_list>
        """)

      assert attribute(html, "dl", "class") == "property-list is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.property_list class={["is-narrow", "is-crisp"]}>
          <:prop label="Name">George</:prop>
        </Doggo.property_list>
        """)

      assert attribute(html, "dl", "class") ==
               "property-list is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.property_list data-test="value">
          <:prop label="Name">George</:prop>
        </Doggo.property_list>
        """)

      assert attribute(html, "dl", "data-test") == "value"
    end
  end

  describe "skeleton/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.skeleton type={:circle} />
        """)

      assert attribute(html, "div:root", "class") == "skeleton is-circle"
    end

    test "with text block" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.skeleton type={:text_block} />
        """)

      assert attribute(html, "div:root", "class") == "skeleton is-text-block"
    end

    test "with rectangle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.skeleton type={:rectangle} />
        """)

      assert attribute(html, "div:root", "class") == "skeleton is-rectangle"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.skeleton type={:text_line} class="is-header" />
        """)

      assert attribute(html, "div:root", "class") ==
               "skeleton is-text-line is-header"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.skeleton type={:image} class={["is-fullwidth", "is-large"]} />
        """)

      assert attribute(html, "div:root", "class") ==
               "skeleton is-image is-fullwidth is-large"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.skeleton type={:square} data-test="hello" />
        """)

      assert attribute(html, "div:root", "data-test") == "hello"
    end
  end

  describe "stack/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack>Hello</Doggo.stack>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "stack"
      assert text(div) == "Hello"
    end

    test "recursive" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack recursive>Hello</Doggo.stack>
        """)

      assert attribute(html, "div", "class") == "stack is-recursive"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack class="is-narrow">Hello</Doggo.stack>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "stack is-narrow"
      assert text(div) == "Hello"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack class={["is-narrow", "is-crisp"]}>Hello</Doggo.stack>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "stack is-narrow is-crisp"
      assert text(div) == "Hello"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack data-what="ever">Hello</Doggo.stack>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "steps/1" do
    test "first step without links" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.steps current_step={0}>
          <:step>Customer Information</:step>
          <:step>Plan</:step>
          <:step>Add-ons</:step>
        </Doggo.steps>
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
        <Doggo.steps current_step={0}>
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </Doggo.steps>
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
        <Doggo.steps current_step={1}>
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </Doggo.steps>
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
        <Doggo.steps current_step={1} linear>
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </Doggo.steps>
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
        <Doggo.steps current_step={0} label="Hops">
          <:step>Customer Information</:step>
        </Doggo.steps>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Hops"
    end

    test "with completed label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.steps current_step={1} completed_label="Done: ">
          <:step>Customer Information</:step>
          <:step>Plan</:step>
        </Doggo.steps>
        """)

      ol = find_one(html, "nav:root ol")
      assert [li1, _] = Floki.children(ol)
      assert text(li1, "span.is-visually-hidden") == "Done:"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.steps current_step={0} class="is-nice">
          <:step>Plan</:step>
        </Doggo.steps>
        """)

      assert attribute(html, "nav:root", "class") == "steps is-nice"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.steps current_step={0} class={["is-nice", "is-ice"]}>
          <:step>Plan</:step>
        </Doggo.steps>
        """)

      assert attribute(html, "nav:root", "class") ==
               "steps is-nice is-ice"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.steps current_step={0} data-test="hello">
          <:step>Plan</:step>
        </Doggo.steps>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end

  describe "switch/1" do
    test "default checked" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.switch label="Subscribe" checked />
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
        <Doggo.switch label="Subscribe" />
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
        <Doggo.switch label="Subscribe" data-test="hello" />
        """)

      assert attribute(html, "button:root", "data-test") == "hello"
    end
  end

  describe "tab_navigation/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tab_navigation current_value={:appointments}>
          <:item href="/profile" value={:show}>Profile</:item>
        </Doggo.tab_navigation>
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
        <Doggo.tab_navigation current_value={:show}>
          <:item href="/profile" value={:show}>Profile</:item>
        </Doggo.tab_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert attribute(a, "aria-current") == "page"
    end

    test "with multiple values" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tab_navigation current_value={:show}>
          <:item href="/profile" value={[:show, :edit]}>Profile</:item>
        </Doggo.tab_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert attribute(a, "aria-current") == "page"
    end

    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tab_navigation current_value={:appointments} label="Tabby">
          <:item href="/profile" value={:show}>Profile</:item>
        </Doggo.tab_navigation>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Tabby"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tab_navigation current_value={:show} class="is-narrow">
          <:item value={[:show, :edit]}>Profile</:item>
        </Doggo.tab_navigation>
        """)

      assert attribute(html, "nav:root", "class") == "tab-navigation is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tab_navigation current_value={:show} class={["is-narrow", "is-crisp"]}>
          <:item value={[:show, :edit]}>Profile</:item>
        </Doggo.tab_navigation>
        """)

      assert attribute(html, "nav:root", "class") ==
               "tab-navigation is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tab_navigation current_value={:show} data-test="hello">
          <:item value={[:show, :edit]}>Profile</:item>
        </Doggo.tab_navigation>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end

  describe "table/1" do
    test "default" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <Doggo.table id="pets" rows={@pets}>
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:action :let={p} label="Link">link-to-<%= p.id %></:action>
        </Doggo.table>
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
        <Doggo.table id="pets" rows={@pets} caption="some text">
          <:col :let={p} label="Name"><%= p.name %></:col>
        </Doggo.table>
        """)

      assert text(html, "table > caption") == "some text"
    end

    test "with col attrs on column" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <Doggo.table id="pets" rows={@pets}>
          <:col :let={p} label="Name" col_attrs={[style: "width: 20%;"]}>
            <%= p.name %>
          </:col>
          <:action :let={p} label="Link">link-to-<%= p.id %></:action>
        </Doggo.table>
        """)

      assert attribute(html, "table > colgroup > col:first-child", "style") ==
               "width: 20%;"
    end

    test "with col attrs on action" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <Doggo.table id="pets" rows={@pets}>
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:action :let={p} label="Link" col_attrs={[style: "width: 20%;"]}>
            link-to-<%= p.id %>
          </:action>
        </Doggo.table>
        """)

      assert attribute(html, "table > colgroup > col:last-child", "style") ==
               "width: 20%;"
    end

    test "with foot" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <Doggo.table id="pets" rows={@pets}>
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:foot>some foot</:foot>
        </Doggo.table>
        """)

      assert text(html, "table > tfoot") == "some foot"
    end

    test "with row id" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <Doggo.table id="pets" rows={@pets} row_id={&"row-#{&1.id}"}>
          <:col :let={p} label="Name"><%= p.name %></:col>
        </Doggo.table>
        """)

      assert attribute(html, "tbody > tr", "id") == "row-1"
    end

    test "with row click" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <Doggo.table id="pets" rows={@pets} row_click={&"clicked-#{&1.id}"}>
          <:col :let={p} label="Name"><%= p.name %></:col>
        </Doggo.table>
        """)

      assert attribute(html, "tbody td", "phx-click") == "clicked-1"
    end

    test "with row item" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <Doggo.table id="pets" rows={@pets} row_item={&Map.put(&1, :name, "G")}>
          <:col :let={p} label="Name"><%= p.name %></:col>
        </Doggo.table>
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
        <Doggo.table id="pets" rows={@pets}>
          <:col :let={{id, p}} label="Name"><%= id %> <%= p.name %></:col>
        </Doggo.table>
        """)

      assert attribute(html, "tbody", "phx-update") == "stream"
      assert attribute(html, "tbody tr:first-child", "id") == "pets-1"
      assert attribute(html, "tbody tr:last-child", "id") == "pets-2"
      assert text(html, "tbody tr:first-child td") == "pets-1 George"
      assert text(html, "tbody tr:last-child td") == "pets-2 Mary"
    end
  end

  describe "tag/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag>value</Doggo.tag>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "tag "
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag size={:medium}>value</Doggo.tag>
        """)

      assert attribute(html, "span", "class") == "tag is-medium"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag variant={:primary}>value</Doggo.tag>
        """)

      assert attribute(html, "span", "class") == "tag is-primary"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag shape={:pill}>value</Doggo.tag>
        """)

      assert attribute(html, "span", "class") == "tag is-pill"
    end
  end

  describe "time/1" do
    test "with Time" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27 18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time
          value={nil}
          formatter={& &1}
          title_formatter={& &1}
          precision={:minute}
          timezone="Asia/Tokyo"
        />
        """)

      assert html == []
    end

    test "with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21]} formatter={&"#{&1.hour}h #{&1.minute}m"} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18h 30m"
    end

    test "with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21]} title_formatter={&"#{&1.hour}h #{&1.minute}m"} />
        """)

      assert attribute(html, "time", "title") == "18h 30m"
    end

    test "with Time and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:microsecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with Time and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:millisecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with Time and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with Time and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with DateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:microsecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with DateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:millisecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with DateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with DateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with NaiveDateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:microsecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with NaiveDateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:millisecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with NaiveDateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with NaiveDateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "03:30:21"
      assert text(time) == "03:30:21"
    end
  end

  describe "toggle_button/1" do
    test "with pressed false" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute">Mute</Doggo.toggle_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "tabindex") == "0"
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-pressed") == "false"
      assert attribute(button, "phx-click") == "toggle-mute"
      assert text(button) == "Mute"
    end

    test "with pressed true" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute" pressed>
          Mute
        </Doggo.toggle_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "tabindex") == "0"
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-pressed") == "true"
      assert attribute(button, "phx-click") == "toggle-mute"
      assert text(button) == "Mute"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute" disabled>
          Mute
        </Doggo.toggle_button>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute" variant={:danger}>
          Mute
        </Doggo.toggle_button>
        """)

      assert attribute(html, "button:root", "class") == "is-danger is-solid"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute" size={:large}>
          Mute
        </Doggo.toggle_button>
        """)

      assert attribute(html, "button:root", "class") ==
               "is-primary is-large is-solid"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute" shape={:pill}>
          Mute
        </Doggo.toggle_button>
        """)

      assert attribute(html, "button:root", "class") ==
               "is-primary is-pill is-solid"
    end

    test "with fill" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute" fill={:outline}>
          Mute
        </Doggo.toggle_button>
        """)

      assert attribute(html, "button:root", "class") == "is-primary is-outline"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.toggle_button on_click="toggle-mute" data-test="hello">
          Mute
        </Doggo.toggle_button>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "tooltip/1" do
    test "with text" do
      id = "text-details"
      expected_id = id <> "-tooltip"
      assigns = %{id: id}

      html =
        parse_heex(~H"""
        <Doggo.tooltip id={@id}>
          some text
          <:tooltip>some details</:tooltip>
        </Doggo.tooltip>
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
        <Doggo.tooltip id={@id} contains_link>
          some link
          <:tooltip>some details</:tooltip>
        </Doggo.tooltip>
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
end
