defmodule DoggoTest do
  use ExUnit.Case
  use Phoenix.Component

  import Doggo.TestHelpers

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

  describe "avatar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" />
        """)

      assert attribute(html, "div:root", "class") == "avatar is-normal"

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

      assert attribute(html, "div:root", "class") ==
               "avatar is-normal is-circle"
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

      assert attribute(html, ":root", "class") == "avatar is-normal has-border"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.avatar src="avatar.png" class={["has-border", "has-shadow"]} />
        """)

      assert attribute(html, ":root", "class") ==
               "avatar is-normal has-border has-shadow"
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

  describe "combobox/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue", "Green"]}
          value="Green"
        />
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "combobox"

      group_div = find_one(div, "div[role='group']")

      input = find_one(group_div, "input")
      assert attribute(input, "id") == "color-selector"
      assert attribute(input, "type") == "text"
      assert attribute(input, "role") == "combobox"
      assert attribute(input, "name") == "color_search"
      assert attribute(input, "value") == "Green"
      assert attribute(input, "aria-autocomplete") == "list"
      assert attribute(input, "aria-expanded") == "false"
      assert attribute(input, "aria-controls") == "color-selector-listbox"
      assert attribute(input, "autocomplete") == "off"

      button = find_one(div, "button")
      assert attribute(button, "id") == "color-selector-button"
      assert attribute(button, "tabindex") == "-1"
      assert attribute(button, "aria-label") == "Colors"
      assert attribute(button, "aria-expanded") == "false"
      assert attribute(button, "aria-controls") == "color-selector-listbox"

      ul = find_one(div, "ul")
      assert attribute(ul, "id") == "color-selector-listbox"
      assert attribute(ul, "role") == "listbox"
      assert attribute(ul, "aria-label") == "Colors"
      assert attribute(ul, "hidden") == "hidden"

      assert li = find_one(ul, "li:first-child")
      assert attribute(li, "role") == "option"
      assert attribute(li, "data-value") == "Blue"
      span = find_one(li, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Blue"

      assert li = find_one(ul, "li:last-child")
      assert attribute(li, "role") == "option"
      assert attribute(li, "data-value") == "Green"
      span = find_one(li, "span:last-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Green"

      input = find_one(div, "input[type='hidden']")
      assert attribute(input, "id") == "color-selector-value"
      assert attribute(input, "name") == "color"
      assert attribute(input, "value") == "Green"
    end

    test "with name using bracket notation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.combobox
          id="color-selector"
          name="dog[color]"
          list_label="Colors"
          options={["Blue", "Green"]}
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "name") == "dog[color_search]"

      input = find_one(html, "input[type='hidden']")
      assert attribute(input, "name") == "dog[color]"
    end

    test "with option labels" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}, {"Green", "green"}]}
          value="green"
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "value") == "Green"

      input = find_one(html, "input[type='hidden']")
      assert attribute(input, "value") == "green"

      ul = find_one(html, "ul")

      li = find_one(ul, "li:first-child")
      assert attribute(li, "data-value") == "blue"
      span = find_one(li, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Blue"

      li = find_one(ul, "li:last-child")
      assert attribute(li, "data-value") == "green"
      span = find_one(li, "span:last-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Green"
    end

    test "with option labels and descriptions" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[
            {"Hakodate", "hakodate", "Hokkaido"},
            {"Kanazawa", "kanazawa", "Ishikawa"}
          ]}
          value="hakodate"
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "value") == "Hakodate"

      input = find_one(html, "input[type='hidden']")
      assert attribute(input, "value") == "hakodate"

      ul = find_one(html, "ul")

      li = find_one(ul, "li:first-child")
      assert attribute(li, "data-value") == "hakodate"
      span = find_one(li, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Hakodate"
      span = find_one(li, "span:last-child")
      assert attribute(span, "class") == "combobox-option-description"
      assert text(span) == "Hokkaido"

      li = find_one(ul, "li:last-child")
      assert attribute(li, "data-value") == "kanazawa"
      span = find_one(li, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Kanazawa"
      span = find_one(li, "span:last-child")
      assert attribute(span, "class") == "combobox-option-description"
      assert text(span) == "Ishikawa"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          data-what="ever"
        />
        """)

      assert attribute(html, ":root", "data-what") == "ever"
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

    test "with header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:header>Doggo</:header>
        </Doggo.drawer>
        """)

      assert text(html, "aside > div.drawer-header") == "Doggo"
    end

    test "with main slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:main>Doggo</:main>
        </Doggo.drawer>
        """)

      assert text(html, "aside > div.drawer-main") == "Doggo"
    end

    test "with footer slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.drawer>
          <:footer>Doggo</:footer>
        </Doggo.drawer>
        """)

      assert text(html, "aside > div.drawer-footer") == "Doggo"
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

  describe "vertical_nav_section/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.vertical_nav_section id="my-drawer">
          <:item>item</:item>
        </Doggo.vertical_nav_section>
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
        <Doggo.vertical_nav_section id="my-drawer">
          <:title>some title</:title>
          <:item>item</:item>
        </Doggo.vertical_nav_section>
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
        <Doggo.vertical_nav_section id="my-drawer">
          <:item class="is-rad">item</:item>
        </Doggo.vertical_nav_section>
        """)

      assert attribute(html, ":root > div", "class") == "drawer-item is-rad"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.vertical_nav_section id="my-drawer" class="is-narrow">
          <:item>item</:item>
        </Doggo.vertical_nav_section>
        """)

      assert attribute(html, ":root", "class") == "drawer-section is-narrow"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.vertical_nav_section id="my-drawer" class={["is-narrow", "is-crisp"]}>
          <:item>item</:item>
        </Doggo.vertical_nav_section>
        """)

      assert attribute(html, ":root", "class") ==
               "drawer-section is-narrow is-crisp"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.vertical_nav_section id="my-drawer" data-test="hello">
          <:item>item</:item>
        </Doggo.vertical_nav_section>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
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
      assert attribute(span, "class") == "icon is-normal"
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

      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == "is-visually-hidden"
      assert text(span) == "some-label"
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
      assert attribute(span, "class") == "icon is-normal has-text-left"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-label"
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
      assert attribute(span, "class") == "icon is-normal has-text-right"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-label"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon class="is-rad">some-icon</Doggo.icon>
        """)

      assert attribute(html, ":root", "class") == "icon is-normal is-rad"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon class={["is-rad", "is-boud"]}>some-icon</Doggo.icon>
        """)

      assert attribute(html, ":root", "class") ==
               "icon is-normal is-rad is-boud"
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
      assert attribute(span, "class") == "icon is-normal"
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
      assert attribute(span, "class") == "icon is-normal"
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

      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == "is-visually-hidden"
      assert text(span) == "some-label"
    end

    test "with label left" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" label="some-label" label_placement={:left} />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon is-normal has-text-left"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-label"
    end

    test "with label right" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" label="some-label" label_placement={:right} />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon is-normal has-text-right"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-label"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" class="is-rad" />
        """)

      assert attribute(html, ":root", "class") == "icon is-normal is-rad"
    end

    test "with additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <Doggo.icon_sprite name="edit" class={["is-rad", "is-boud"]} />
        """)

      assert attribute(html, ":root", "class") ==
               "icon is-normal is-rad is-boud"
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

      input = find_one(html, "input")
      assert attribute(input, "id") == "age"
      assert attribute(input, "name") == "age"
      assert attribute(input, "type") == "text"
      assert attribute(input, "aria-describedby") == nil
      assert attribute(input, "aria-invalid") == nil
      assert attribute(input, "aria-errormessage") == nil

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

      assert attribute(html, "input", "aria-invalid") == "true"
      assert attribute(html, "input", "aria-errormessage") == "species_errors"
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

      assert attribute(html, "input", "aria-invalid") == "true"
      assert attribute(html, "input", "aria-errormessage") == "species_errors"

      assert attribute(html, "input", "aria-describedby") ==
               "species_description"

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

    test "hides errors if field is unused" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={%{@form[:what] | errors: [{"weird", []}]}} />
        </.form>
        """)

      assert Floki.find(html, ".field-errors") == []

      assigns = %{form: to_form(%{"what" => "what", "_unused_what" => ""})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <Doggo.input field={%{@form[:what] | errors: [{"weird", []}]}} />
        </.form>
        """)

      assert Floki.find(html, ".field-errors") == []
    end

    test "inserts gettext variables in errors without gettext module" do
      assigns = %{form: to_form(%{"what" => "what"})}

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
      assigns = %{form: to_form(%{"what" => "what"})}

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
      assigns = %{form: to_form(%{"what" => "what"})}

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

      mark = find_one(html, "label > span.label-required")
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

      assert attribute(html, "label > span.label-required", "title") ==
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

  describe "modifier_classes/1" do
    test "returns a map of modifier classes" do
      assert %{variants: [variant | _]} = Doggo.modifier_classes()
      assert is_binary(variant)
    end
  end
end
