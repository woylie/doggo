defmodule DoggoTest do
  use ExUnit.Case
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS

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

      ul = find_one(html, "nav:root > ul")
      assert [li1, li2, li3] = Floki.children(ul)

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
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.frame ratio={{16, 9}}>image</Doggo.frame>
        """)

      assert attribute(html, "div", "class") == "frame is-16-to-9"
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
