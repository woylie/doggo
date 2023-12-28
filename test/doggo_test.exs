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

      div = Floki.find(html, "div")
      assert attribute(div, "class") == "action-bar"

      a = Floki.find(div, "a")
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

      div = Floki.find(html, "div")
      assert attribute(div, "class") == "action-bar is-narrow"
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

      div = Floki.find(html, "div")
      assert attribute(div, "class") == "action-bar is-narrow is-crisp"
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

      div = Floki.find(html, "div")
      assert attribute(div, "data-what") == "ever"
    end
  end

  describe "app_bar/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<Doggo.app_bar></Doggo.app_bar>")
      header = Floki.find(html, "header")
      assert attribute(header, "class") == "app-bar"
      assert Floki.children(header) == nil
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar title="Some Title"></Doggo.app_bar>
        """)

      h1 = Floki.find(html, "header h1")
      assert text(h1) == "Some Title"
    end

    test "with navigation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar>
          <:navigation label="Back" on_click="back">back-icon</:navigation>
        </Doggo.app_bar>
        """)

      div = Floki.find(html, "header div.app-bar-navigation")
      a = Floki.find(div, "a")
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

      div = Floki.find(html, "header div.app-bar-actions")
      a = Floki.find(div, "a")
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

      header = Floki.find(html, "header")
      assert attribute(header, "class") == "app-bar is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar class={["is-narrow", "is-crisp"]}></Doggo.app_bar>
        """)

      header = Floki.find(html, "header")
      assert attribute(header, "class") == "app-bar is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.app_bar data-what="ever"></Doggo.app_bar>
        """)

      header = Floki.find(html, "header")
      assert attribute(header, "data-what") == "ever"
    end
  end

  describe "badge/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.badge>value</Doggo.badge>
        """)

      span = Floki.find(html, "span")
      assert attribute(span, "class") == "badge "
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.badge size={:large}>value</Doggo.badge>
        """)

      span = Floki.find(html, "span")
      assert attribute(span, "class") == "badge is-large"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.badge variant={:secondary}>value</Doggo.badge>
        """)

      span = Floki.find(html, "span")
      assert attribute(span, "class") == "badge is-secondary"
    end
  end

  describe "card/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<Doggo.card></Doggo.card>")
      article = Floki.find(html, "article")
      assert attribute(article, "class") == "card"
      assert Floki.children(article) == nil
    end

    test "with figure" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:image>Doggo</:image>
        </Doggo.card>
        """)

      div = Floki.find(html, "article figure")
      assert text(div) == "Doggo"
    end

    test "with header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:header>Doggo</:header>
        </Doggo.card>
        """)

      div = Floki.find(html, "article header")
      assert text(div) == "Doggo"
    end

    test "with main" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:main>Doggo</:main>
        </Doggo.card>
        """)

      div = Floki.find(html, "article main")
      assert text(div) == "Doggo"
    end

    test "with footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card>
          <:footer>Doggo</:footer>
        </Doggo.card>
        """)

      div = Floki.find(html, "article footer")
      assert text(div) == "Doggo"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card class="is-narrow"></Doggo.card>
        """)

      article = Floki.find(html, "article")
      assert attribute(article, "class") == "card is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card class={["is-narrow", "is-crisp"]}></Doggo.card>
        """)

      article = Floki.find(html, "article")
      assert attribute(article, "class") == "card is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.card data-what="ever"></Doggo.card>
        """)

      article = Floki.find(html, "article")
      assert attribute(article, "data-what") == "ever"
    end
  end

  describe "date/1" do
    test "with Date" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~D[2023-12-27]} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~N[2023-12-27T18:30:21]} />
        """)

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

      assert attribute(time, "title") == "2023/12/27"
      assert text(time) == "2023-12-27"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.date value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27 18:30:21]} />
        """)

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107Z"
      assert text(time) == "2023-12-27 18:30:21.107Z"
    end

    test "with DateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~U[2023-12-27T18:30:21.107074Z]} precision={:second} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "with DateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~U[2023-12-27T18:30:21.107074Z]} precision={:minute} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00Z"
      assert text(time) == "2023-12-27 18:30:00Z"
    end

    test "with NaiveDateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:microsecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107074"
      assert text(time) == "2023-12-27 18:30:21.107074"
    end

    test "with NaiveDateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:millisecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107"
      assert text(time) == "2023-12-27 18:30:21.107"
    end

    test "with NaiveDateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:second} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "2023-12-27 18:30:21"
    end

    test "with NaiveDateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~N[2023-12-27T18:30:21.107074]} precision={:minute} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00"
      assert text(time) == "2023-12-27 18:30:00"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.datetime value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "2023-12-28T03:30:21+09:00"
      assert text(time) == "2023-12-28 03:30:21+09:00 JST Asia/Tokyo"
    end
  end

  describe "drawer/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<Doggo.drawer></Doggo.drawer>")
      aside = Floki.find(html, "aside")
      assert attribute(aside, "class") == "drawer"
      assert Floki.children(aside) == nil
    end

    test "with brand" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:brand>Doggo</:brand>
        </Doggo.drawer>
        """)

      div = Floki.find(html, "aside div.drawer-brand")
      assert text(div) == "Doggo"
    end

    test "with top slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:top>Doggo</:top>
        </Doggo.drawer>
        """)

      div = Floki.find(html, "aside div.drawer-top")
      assert text(div) == "Doggo"
    end

    test "with bottom slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:bottom>Doggo</:bottom>
        </Doggo.drawer>
        """)

      div = Floki.find(html, "aside div.drawer-bottom")
      assert text(div) == "Doggo"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer class="is-narrow"></Doggo.drawer>
        """)

      aside = Floki.find(html, "aside")
      assert attribute(aside, "class") == "drawer is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer class={["is-narrow", "is-crisp"]}></Doggo.drawer>
        """)

      aside = Floki.find(html, "aside")
      assert attribute(aside, "class") == "drawer is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer data-what="ever"></Doggo.drawer>
        """)

      aside = Floki.find(html, "aside")
      assert attribute(aside, "data-what") == "ever"
    end
  end

  describe "field_group/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group>fields</Doggo.field_group>
        """)

      div = Floki.find(html, "div")
      assert attribute(div, "class") == "field-group"
      assert text(div) == "fields"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group class="is-narrow">fields</Doggo.field_group>
        """)

      div = Floki.find(html, "div")
      assert attribute(div, "class") == "field-group is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group class={["is-narrow", "is-crisp"]}>
          fields
        </Doggo.field_group>
        """)

      div = Floki.find(html, "div")
      assert attribute(div, "class") == "field-group is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.field_group data-what="ever">fields</Doggo.field_group>
        """)

      div = Floki.find(html, "div")
      assert attribute(div, "data-what") == "ever"
    end
  end

  describe "stack/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack>Hello</Doggo.stack>
        """)

      div = Floki.find(html, "div")

      assert attribute(div, "class") == "stack"
      assert text(div) == "Hello"
    end

    test "recursive" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack recursive>Hello</Doggo.stack>
        """)

      div = Floki.find(html, "div")
      assert attribute(div, "class") == "stack is-recursive"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack class="is-narrow">Hello</Doggo.stack>
        """)

      div = Floki.find(html, "div")

      assert attribute(div, "class") == "stack is-narrow"
      assert text(div) == "Hello"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack class={["is-narrow", "is-crisp"]}>Hello</Doggo.stack>
        """)

      div = Floki.find(html, "div")

      assert attribute(div, "class") == "stack is-narrow is-crisp"
      assert text(div) == "Hello"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.stack data-what="ever">Hello</Doggo.stack>
        """)

      div = Floki.find(html, "div")
      assert attribute(div, "data-what") == "ever"
    end
  end

  describe "tag/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag>value</Doggo.tag>
        """)

      span = Floki.find(html, "span")
      assert attribute(span, "class") == "tag "
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag size={:medium}>value</Doggo.tag>
        """)

      span = Floki.find(html, "span")
      assert attribute(span, "class") == "tag is-medium"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag variant={:primary}>value</Doggo.tag>
        """)

      span = Floki.find(html, "span")
      assert attribute(span, "class") == "tag is-primary"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.tag shape={:pill}>value</Doggo.tag>
        """)

      span = Floki.find(html, "span")
      assert attribute(span, "class") == "tag is-pill"
    end
  end

  describe "time/1" do
    test "with Time" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21]} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27 18:30:21]} />
        """)

      time = Floki.find(html, "time")

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

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18h 30m"
    end

    test "with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21]} title_formatter={&"#{&1.hour}h #{&1.minute}m"} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "title") == "18h 30m"
    end

    test "with Time and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:microsecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with Time and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:millisecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with Time and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:second} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with Time and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~T[18:30:21.107074]} precision={:minute} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with DateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:microsecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with DateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:millisecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with DateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:second} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with DateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21.107074Z]} precision={:minute} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with NaiveDateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:microsecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with NaiveDateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:millisecond} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with NaiveDateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:second} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with NaiveDateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~N[2023-12-27T18:30:21.107074]} precision={:minute} />
        """)

      time = Floki.find(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.time value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = Floki.find(html, "time")

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

      span = Floki.find(html, "span")
      assert attribute(span, "data-aria-tooltip") == "data-aria-tooltip"
      assert attribute(span, "aria-describedby") == expected_id

      inner_span = Floki.find(html, "span > span")
      assert attribute(inner_span, "tabindex") == "0"
      assert text(inner_span) == "some text"

      tooltip = Floki.find(html, "span > div[role='tooltip']")
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

      span = Floki.find(html, "span")
      assert attribute(span, "data-aria-tooltip") == "data-aria-tooltip"
      assert attribute(span, "aria-describedby") == expected_id

      inner_span = Floki.find(html, "span > span")
      assert attribute(inner_span, "tabindex") == nil
      assert text(inner_span) == "some link"

      tooltip = Floki.find(html, "span > div[role='tooltip']")
      assert attribute(tooltip, "id") == expected_id
      assert text(tooltip) == "some details"
    end
  end
end
