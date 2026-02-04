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

    use Doggo.Components
    use Phoenix.Component

    build_badge()
    build_bottom_navigation()
    build_box()
    build_breadcrumb()
    build_button()
    build_button_link()
    build_callout()
    build_card()
    build_carousel()
    build_cluster()
    build_combobox()
    build_date()
    build_datetime()
    build_disclosure_button()
    build_drawer()
    build_fallback()
    build_field(gettext_module: Doggo.Gettext)
    build_field_group()
    build_frame()
    build_icon(icon_module: __MODULE__.Icons)

    build_icon(
      icon_module: __MODULE__.Icons,
      icon_fun: :render,
      name: :icon_with_fun
    )

    build_icon_sprite()
    build_image()
    build_menu()
    build_menu_bar()
    build_menu_button()
    build_menu_group()
    build_menu_item()
    build_menu_item_checkbox()
    build_menu_item_radio_group()
    build_modal()
    build_navbar()
    build_navbar_items()
    build_page_header()
    build_property_list()
    build_radio_group()
    build_skeleton()
    build_split_pane()
    build_stack()
    build_steps()
    build_switch()
    build_tab_navigation()
    build_table()
    build_tabs()
    build_tag()
    build_time()
    build_toggle_button()
    build_toolbar()
    build_tooltip()
    build_tree()
    build_tree_item()
    build_vertical_nav()
    build_vertical_nav_nested()
    build_vertical_nav_section()

    defmodule Icons do
      use Phoenix.Component

      def render(assigns) do
        ~H"""
        <svg class={@name}></svg>
        """
      end

      def info(assigns) do
        ~H"""
        <svg class="info"></svg>
        """
      end
    end
  end

  describe "__dog_components__/0" do
    test "returns map of components" do
      assert %{button_link: _} = TestComponents.__dog_components__()
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
      assert attribute(span, "class") == "badge"
      assert attribute(span, "data-size") == "normal"
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge size="large">value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge"
      assert attribute(span, "data-size") == "large"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.badge variant="secondary">value</TestComponents.badge>
        """)

      span = find_one(html, "span")
      assert attribute(span, "class") == "badge"
      assert attribute(span, "data-variant") == "secondary"
      assert attribute(span, "data-size") == "normal"
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

  describe "bottom_navigation/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:appointments}>
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "bottom-navigation"

      a = find_one(nav, "ul > li > a")
      assert attribute(a, "aria-current") == nil
      assert attribute(a, "aria-label") == "Profile"
      assert attribute(a, "href") == "/profile"

      assert text(a, "span.bottom-navigation-icon") == "profile-icon"
      assert text(a, "span:last-child") == "Profile"
    end

    test "with aria label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:appointments} label="Main">
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Main"
    end

    test "with hide_labels" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:appointments} hide_labels>
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      a = find_one(html, "nav:root > ul > li > a")
      assert [span] = Floki.children(a)
      assert attribute(span, "class") == "bottom-navigation-icon"
    end

    test "with single value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:show}>
          <:item label="Profile" href="/profile" value={:show}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root > ul > li > a", "aria-current") == "page"
    end

    test "with multiple values" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:show}>
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root > ul > li > a", "aria-current") == "page"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.bottom_navigation current_value={:show} data-test="hello">
          <:item label="Profile" href="/profile" value={[:show, :edit]}>
            profile-icon
          </:item>
        </TestComponents.bottom_navigation>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
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
      assert attribute(section, "aria-labelledby") == nil
      body = find_one(section, ".box-body")
      assert text(body) == "Content"
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

      assert attribute(button, "class") == "button"
      assert attribute(button, "data-variant") == "primary"
      assert attribute(button, "data-size") == "normal"
      assert attribute(button, "data-fill") == "solid"

      assert text(button) == "Confirm"
    end

    test "with additional class as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button class="mt-4">Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")

      assert attribute(button, "class") == "button mt-4"
    end

    test "with multiple additional classes as string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button class="mt-4 mb-2">Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")

      assert attribute(button, "class") == "button mt-4 mb-2"
    end

    test "with multiple additional classes as list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button class={["mt-4", "mb-2"]}>Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")

      assert attribute(button, "class") == "button mt-4 mb-2"
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

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-variant") == "danger"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button size="large">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-size") == "large"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button shape="pill">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-shape") == "pill"
    end

    test "with fill" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button fill="outline">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-fill") == "outline"
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
      assert attribute(a, "class") == "button"
      assert attribute(a, "data-variant") == "primary"
      assert attribute(a, "data-size") == "normal"
      assert attribute(a, "data-fill") == "solid"
      assert attribute(a, "href") == "/confirm"
      assert text(a) == "Confirm"
    end

    test "disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled>Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-disabled") == "data-disabled"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link variant="info">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-variant") == "info"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link size="small">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-size") == "small"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link shape="pill">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-shape") == "pill"
    end

    test "with fill" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link fill="text">Confirm</TestComponents.button_link>
        """)

      assert attribute(html, "a:root", "class") == "button"
      assert attribute(html, "a:root", "data-fill") == "text"
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

  describe "callout/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.callout id="my-callout">Did you know?</TestComponents.callout>
        """)

      aside = find_one(html, "aside:root")
      assert attribute(aside, "class") == "callout"
      assert attribute(aside, "data-variant") == "info"
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
        <TestComponents.callout id="my-callout" title="Did you know?">
          Know what?
        </TestComponents.callout>
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
        <TestComponents.callout id="my-callout">
          <:icon>lightbulb</:icon>
          Did you know?
        </TestComponents.callout>
        """)

      assert text(html, "aside:root > .callout-icon") == "lightbulb"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.callout id="my-callout" data-test="hello">
          Did you know?
        </TestComponents.callout>
        """)

      assert attribute(html, "aside:root", "data-test") == "hello"
    end
  end

  describe "card/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<TestComponents.card></TestComponents.card>")
      article = find_one(html, "article")
      assert attribute(article, "class") == "card"
      assert Floki.children(article) == []
    end

    test "with figure" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:image>Doggo</:image>
        </TestComponents.card>
        """)

      assert text(html, "article > figure") == "Doggo"
    end

    test "with header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:header>Doggo</:header>
        </TestComponents.card>
        """)

      assert text(html, "article > header") == "Doggo"
    end

    test "with main" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:main>Doggo</:main>
        </TestComponents.card>
        """)

      assert text(html, "article > main") == "Doggo"
    end

    test "with footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:footer>Doggo</:footer>
        </TestComponents.card>
        """)

      assert text(html, "article > footer") == "Doggo"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card data-what="ever"></TestComponents.card>
        """)

      assert attribute(html, "article", "data-what") == "ever"
    end
  end

  describe "carousel/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:item label="1 of 2">A</:item>
          <:item label="2 of 2">B</:item>
        </TestComponents.carousel>
        """)

      section = find_one(html, "section:root")
      assert attribute(section, "class") == "carousel"
      assert attribute(section, "id") == "dog-carousel"
      assert attribute(section, "aria-roledescription") == "carousel"
      assert attribute(section, "aria-label") == "Dog Carousel"

      items = find_one(html, ":root > .carousel-inner > .carousel-items")
      assert attribute(items, "aria-live") == "polite"

      div = find_one(items, "> .carousel-item:first-child")
      assert attribute(div, "id") == "dog-carousel-item-1"
      assert attribute(div, "role") == "group"
      assert attribute(div, "aria-label") == "1 of 2"
      assert text(div) == "A"

      div = find_one(items, "> .carousel-item:last-child")
      assert attribute(div, "id") == "dog-carousel-item-2"
      assert attribute(div, "role") == "group"
      assert attribute(div, "aria-label") == "2 of 2"
      assert text(div) == "B"
    end

    test "with previous and next buttons" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:previous label="Previous Slide">Previous</:previous>
          <:next label="Next Slide">Next</:next>
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
        """)

      div = find_one(html, ":root > .carousel-inner > .carousel-controls")

      button = find_one(div, "button.carousel-previous")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-controls") == "dog-carousel-items"
      assert attribute(button, "aria-label") == "Previous Slide"
      assert text(button) == "Previous"

      button = find_one(div, "button.carousel-next")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-controls") == "dog-carousel-items"
      assert attribute(button, "aria-label") == "Next Slide"
      assert text(button) == "Next"
    end

    test "with pagination" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel
          id="dog-carousel"
          label="Dog Carousel"
          pagination_label="スライド"
          pagination_slide_label={&"スライド#{&1}"}
          pagination
        >
          <:item label="1 of 2">A</:item>
          <:item label="2 of 2">B</:item>
        </TestComponents.carousel>
        """)

      div = find_one(html, ".carousel-controls > .carousel-pagination > div")
      assert attribute(div, "role") == "tablist"
      assert attribute(div, "aria-label") == "スライド"

      assert button = find_one(div, "button:first-child")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "tab"
      assert attribute(button, "aria-label") == "スライド1"
      assert attribute(button, "aria-controls") == "dog-carousel-item-1"

      assert button = find_one(div, "button:last-child")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "tab"
      assert attribute(button, "aria-label") == "スライド2"
      assert attribute(button, "aria-controls") == "dog-carousel-item-2"
    end

    test "with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" labelledby="dog-carousel-label">
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "dog-carousel-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.carousel
          id="dog-carousel"
          label="Dog Carousel"
          labelledby="dog-carousel-label"
        >
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel">
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
        """)
      end
    end

    test "with role descriptions" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel
          id="dog-carousel"
          label="Dog Carousel"
          carousel_roledescription="カルーセル"
          slide_roledescription="スライド"
        >
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
        """)

      assert attribute(html, ":root", "aria-roledescription") == "カルーセル"

      assert attribute(
               html,
               ".carousel-item:first-child",
               "aria-roledescription"
             ) == "スライド"
    end

    test "with auto_rotation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel" auto_rotation>
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
        """)

      div = find_one(html, ":root > .carousel-inner > .carousel-items")
      assert attribute(div, "aria-live") == "off"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel
          id="dog-carousel"
          label="Dog Carousel"
          data-test="hello"
        >
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
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

  describe "combobox/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.combobox
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
        <TestComponents.combobox
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
        <TestComponents.combobox
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
        <TestComponents.combobox
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
        <TestComponents.combobox
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
        <TestComponents.date value={~D[2023-12-27]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~N[2023-12-27T18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date
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
        <TestComponents.date
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
        <TestComponents.date
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
        <TestComponents.date value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
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
        <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~N[2023-12-27 18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "2023-12-27 18:30:21"
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
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
        <TestComponents.datetime
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
        <TestComponents.datetime
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
        <TestComponents.datetime
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
        <TestComponents.datetime
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
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:second}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "with DateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:minute}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00Z"
      assert text(time) == "2023-12-27 18:30:00Z"
    end

    test "with NaiveDateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107074"
      assert text(time) == "2023-12-27 18:30:21.107074"
    end

    test "with NaiveDateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107"
      assert text(time) == "2023-12-27 18:30:21.107"
    end

    test "with NaiveDateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:second}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "2023-12-27 18:30:21"
    end

    test "with NaiveDateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:minute}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00"
      assert text(time) == "2023-12-27 18:30:00"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-28T03:30:21+09:00"
      assert text(time) == "2023-12-28 03:30:21+09:00 JST Asia/Tokyo"
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

  describe "drawer/1" do
    test "default" do
      assigns = %{}
      html = parse_heex(~H"<TestComponents.drawer></TestComponents.drawer>")
      aside = find_one(html, "aside")
      assert attribute(aside, "class") == "drawer"
      assert Floki.children(aside) == []
    end

    test "with header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer>
          <:header>Doggo</:header>
        </TestComponents.drawer>
        """)

      assert text(html, "aside > div.drawer-header") == "Doggo"
    end

    test "with main slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer>
          <:main>Doggo</:main>
        </TestComponents.drawer>
        """)

      assert text(html, "aside > div.drawer-main") == "Doggo"
    end

    test "with footer slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer>
          <:footer>Doggo</:footer>
        </TestComponents.drawer>
        """)

      assert text(html, "aside > div.drawer-footer") == "Doggo"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.drawer data-what="ever"></TestComponents.drawer>
        """)

      assert attribute(html, "aside", "data-what") == "ever"
    end
  end

  describe "field_group/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field_group>fields</TestComponents.field_group>
        """)

      div = find_one(html, "div")
      assert attribute(div, "class") == "field-group"
      assert text(div) == "fields"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field_group data-what="ever">fields</TestComponents.field_group>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end

  describe "frame/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.frame>image</TestComponents.frame>
        """)

      assert attribute(html, "div", "class") == "frame"
      assert text(html, "div") == "image"
    end

    test "with ratio" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.frame ratio="16:9">image</TestComponents.frame>
        """)

      assert attribute(html, "div", "class") == "frame"
      assert attribute(html, "div", "data-numerator") == "16"
      assert attribute(html, "div", "data-denominator") == "9"
    end

    test "with circle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.frame shape="circle">image</TestComponents.frame>
        """)

      assert attribute(html, "div", "class") == "frame"
      assert attribute(html, "div", "data-shape") == "circle"
    end
  end

  describe "fallback/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value="dog" />
        """)

      assert html == ["dog"]
    end

    test "with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value="dog" formatter={&String.upcase/1} />
        """)

      assert html == ["DOG"]
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value={nil} />
        """)

      assert html == [
               {"span", [{"class", "fallback"}, {"aria-label", "not set"}],
                ["-"]}
             ]
    end

    test "with empty string and formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value="" formatter={&String.upcase/1} />
        """)

      assert html == [
               {"span", [{"class", "fallback"}, {"aria-label", "not set"}],
                ["-"]}
             ]
    end

    test "with placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value={[]} placeholder="n/a" />
        """)

      assert html == [
               {"span", [{"class", "fallback"}, {"aria-label", "not set"}],
                ["n/a"]}
             ]
    end

    test "with accessibility text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value={[]} accessibility_text="not available" />
        """)

      assert html == [
               {"span",
                [{"class", "fallback"}, {"aria-label", "not available"}], ["-"]}
             ]
    end
  end

  describe "icon/1" do
    test "with module" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"

      assert find_one(html, "svg.info")
    end

    test "with module and function" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_with_fun name="warning" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"

      assert find_one(html, "svg.warning")
    end

    test "with text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" text="some-text" />
        """)

      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == "is-visually-hidden"
      assert text(span) == "some-text"

      assert find_one(html, "svg.info")
    end

    test "with text before" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" text="some-text" text_position="before" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-before"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-text"
    end

    test "with text after" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" text="some-text" text_position="after" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-after"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-text"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon name="info" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "icon_sprite/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon"
      svg = find_one(span, "svg")
      assert attribute(svg, "aria-hidden") == "true"
      assert attribute(svg, "use", "href") == "/assets/icons/sprite.svg#edit"
    end

    test "with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" text="some-text" />
        """)

      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == "is-visually-hidden"
      assert text(span) == "some-text"
    end

    test "with text left" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" text="some-text" text_position="before" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-before"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-text"
    end

    test "with text after" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" text="some-text" text_position="after" />
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "class") == "icon has-text-after"
      assert span = find_one(html, "span > span")
      assert attribute(span, "class") == ""
      assert text(span) == "some-text"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.icon_sprite name="edit" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "image/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" />
        """)

      figure = find_one(html, "figure:root")
      assert attribute(figure, "class") == "image"

      img = find_one(html, ":root > .image-frame > img")
      assert attribute(img, "src") == "image.png"
      assert attribute(img, "alt") == "some text"
      assert attribute(img, "loading") == "lazy"
      assert Floki.find(html, "caption") == []
    end

    test "with width and height" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" width={300} height={200} />
        """)

      img = find_one(html, ":root > .image-frame > img")
      assert attribute(img, "width") == "300"
      assert attribute(img, "height") == "200"
    end

    test "with loading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" loading="eager" />
        """)

      assert attribute(html, "img", "loading") == "eager"
    end

    test "with ratio" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" ratio="3:2" />
        """)

      assert attribute(html, ":root", "class") == "image"
      assert attribute(html, ":root", "data-numerator") == "3"
      assert attribute(html, ":root", "data-denominator") == "2"
    end

    test "with caption" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text">
          <:caption>some caption</:caption>
        </TestComponents.image>
        """)

      assert text(html, ":root > figcaption") == "some caption"
    end

    test "with srcset as string" do
      srcset = "images/image-1x.jpg 1x, images/image-2x.jpg 2x"
      assigns = %{srcset: srcset}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" srcset={@srcset} />
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
        <TestComponents.image src="image.png" alt="some text" srcset={@srcset} />
        """)

      assert attribute(html, "img", "srcset") == srcset_str
    end

    test "with sizes" do
      sizes = "(max-width: 30em) 20em"
      assigns = %{sizes: sizes}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" sizes={@sizes} />
        """)

      assert attribute(html, "img", "sizes") == sizes
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "menu/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu label="Dog actions">
          <:item>A</:item>
        </TestComponents.menu>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "menu"
      assert attribute(ul, "aria-label") == "Dog actions"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"
      assert text(li) == "A"
    end

    test "with separator" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu label="Dog actions">
          <:item role="separator">A</:item>
        </TestComponents.menu>
        """)

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "separator"
      assert text(li) == ""
    end

    test "with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu labelledby="dog-menu-label">
          <:item>A</:item>
        </TestComponents.menu>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "dog-menu-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu label="Dog actions" labelledby="dog-menu-label">
          <:item>A</:item>
        </TestComponents.menu>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu>
          <:item>A</:item>
        </TestComponents.menu>
        """)
      end
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu label="Dog actions" data-test="hello">
          <:item>A</:item>
        </TestComponents.menu>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "menu_bar/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar label="Dog actions">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "menubar"
      assert attribute(ul, "aria-label") == "Dog actions"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"
      assert text(li) == "A"
    end

    test "with separator" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar label="Dog actions">
          <:item role="separator">A</:item>
        </TestComponents.menu_bar>
        """)

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "separator"
      assert text(li) == ""
    end

    test "with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar labelledby="dog-menu-label">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "dog-menu-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu_bar label="Dog actions" labelledby="dog-menu-label">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu_bar>
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)
      end
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar label="Dog actions" data-test="hello">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "menu_button/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_button controls="actions-menu" id="actions-button">
          Menu
        </TestComponents.menu_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "id") == "actions-button"
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-haspopup") == "true"
      assert attribute(button, "aria-expanded") == "false"
      assert attribute(button, "aria-controls") == "actions-menu"
      assert attribute(button, "role") == nil
      assert text(button) == "Menu"
    end

    test "as menu item" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_button controls="actions-menu" id="actions-button" menuitem>
          Menu
        </TestComponents.menu_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "role") == "menuitem"
    end
  end

  describe "menu_group/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_group label="Dog actions">
          <:item>A</:item>
        </TestComponents.menu_group>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "group"
      assert attribute(ul, "aria-label") == "Dog actions"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"
      assert text(li) == "A"
    end

    test "with separator" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_group label="Dog actions">
          <:item role="separator">A</:item>
        </TestComponents.menu_group>
        """)

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "separator"
      assert text(li) == ""
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_group label="Dog actions" data-test="hello">
          <:item>A</:item>
        </TestComponents.menu_group>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
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

    test "with navigation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.page_header title="Pets">
          <:navigation navigate="/pets">Back to pets</:navigation>
        </TestComponents.page_header>
        """)

      assert text(html, ":root > .page-header-navigation > a") == "Back to pets"

      assert attribute(html, ":root > .page-header-navigation > a", "href") ==
               "/pets"
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

      assert attribute(html, "div:root", "class") == "skeleton"
      assert attribute(html, "div:root", "data-type") == "circle"
    end

    test "with text block" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.skeleton type="text-block" />
        """)

      assert attribute(html, "div:root", "class") == "skeleton"
      assert attribute(html, "div:root", "data-type") == "text-block"
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
      refute attribute(html, "div", "data-recursive")
      assert text(div) == "Hello"
    end

    test "recursive" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.stack recursive>Hello</TestComponents.stack>
        """)

      assert attribute(html, "div", "class") == "stack"
      assert attribute(html, "div", "data-recursive") == "data-recursive"
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

      assert attribute(li1, "data-state") == "current"
      assert attribute(li2, "data-state") == "upcoming"
      assert attribute(li3, "data-state") == "upcoming"

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

      assert text(li1, "span[data-visually-hidden]") == "Completed:"
      assert text(li1, "a") == "Customer Information"
      assert text(li2, "span") == "Plan"
      assert text(li3, "a") == "Add-ons"

      assert attribute(li1, "a", "phx-click") == "to-customer-info"
      assert attribute(li3, "a", "phx-click") == "to-add-ons"

      assert attribute(li1, "data-state") == "completed"
      assert attribute(li2, "data-state") == "current"
      assert attribute(li3, "data-state") == "upcoming"
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

      assert text(li1, "span[data-visually-hidden]") == "Completed:"
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
      assert text(li1, "span[data-visually-hidden]") == "Done:"
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
          <:col :let={p} label="Name">{p.name}</:col>
          <:action :let={p} label="Link">link-to-{p.id}</:action>
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
          <:col :let={p} label="Name">{p.name}</:col>
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
            {p.name}
          </:col>
          <:action :let={p} label="Link">link-to-{p.id}</:action>
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
          <:col :let={p} label="Name">{p.name}</:col>
          <:action :let={p} label="Link" col_attrs={[style: "width: 20%;"]}>
            link-to-{p.id}
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
          <:col :let={p} label="Name">{p.name}</:col>
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
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody > tr", "id") == "row-1"
    end

    test "with row click" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_click={&"clicked-#{&1.id}"}>
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody td", "phx-click") == "clicked-1"
    end

    test "with row item" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_item={&Map.put(&1, :name, "G")}>
          <:col :let={p} label="Name">{p.name}</:col>
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
          <:col :let={{id, p}} label="Name">{id} {p.name}</:col>
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
      assert attribute(span, "class") == "tag"
      assert attribute(span, "data-size") == "normal"
      assert text(span) == "value"
    end

    test "with size" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag size="medium">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag"
      assert attribute(html, "span", "data-size") == "medium"
    end

    test "with variant" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag variant="primary">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag"
      assert attribute(html, "span", "data-variant") == "primary"
    end

    test "with shape" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tag shape="pill">value</TestComponents.tag>
        """)

      assert attribute(html, "span", "class") == "tag"
      assert attribute(html, "span", "data-shape") == "pill"
      assert attribute(html, "span", "data-size") == "normal"
    end
  end

  describe "time/1" do
    test "with Time" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~N[2023-12-27 18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
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
        <TestComponents.time
          value={~T[18:30:21]}
          formatter={&"#{&1.hour}h #{&1.minute}m"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18h 30m"
    end

    test "with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~T[18:30:21]}
          title_formatter={&"#{&1.hour}h #{&1.minute}m"}
        />
        """)

      assert attribute(html, "time", "title") == "18h 30m"
    end

    test "with Time and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:microsecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with Time and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:millisecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with Time and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with Time and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with DateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with DateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with DateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:second}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with DateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:minute}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with NaiveDateTime and microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "with NaiveDateTime and millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "with NaiveDateTime and second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~N[2023-12-27T18:30:21.107074]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "with NaiveDateTime and minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~N[2023-12-27T18:30:21.107074]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "with DateTime and time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
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

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-variant") == "danger"
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

  describe "vertical_nav/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:item>item</:item>
        </TestComponents.vertical_nav>
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
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:item current_page>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, ":root > ul > li", "aria-current") == "page"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:title>some title</:title>
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert text(html, ":root > div.vertical-nav-title") == "some title"
    end

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:item class="is-rad">item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, "li", "class") == "is-rad"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main" data-test="hello">
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end

  describe "vertical_nav_nested/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:item>item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      assert attribute(html, "div:root > ul", "id") == "nested"
      li = find_one(html, "div:root > ul li")
      assert attribute(li, "aria-labelledby") == nil
      assert text(li) == "item"
      assert Floki.find(html, ".drawer-nav-title") == []
    end

    test "with current page" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:item current_page>item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      assert attribute(html, "div:root > ul > li", "aria-current") == "page"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:title>some title</:title>
          <:item>item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      div = find_one(html, "div.vertical-nav-nested-title")
      assert attribute(div, "id") == "nested-title"
      assert text(div) == "some title"

      assert attribute(html, "div:root > ul", "aria-labelledby") ==
               "nested-title"
    end

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:item class="is-rad">item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      assert attribute(html, "li", "class") == "is-rad"
    end
  end

  describe "vertical_nav_section/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer">
          <:item>item</:item>
        </TestComponents.vertical_nav_section>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "vertical-nav-section"
      assert attribute(div, "id") == "my-drawer"
      assert attribute(div, "aria-labelledby") == nil
      assert Floki.find(html, ".vertical-nav-section-title") == []
      assert text(html, ":root > div.vertical-nav-section-item") == "item"
    end

    test "with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer">
          <:title>some title</:title>
          <:item>item</:item>
        </TestComponents.vertical_nav_section>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "aria-labelledby") == "my-drawer-title"

      div = find_one(html, "div > .vertical-nav-section-title")
      assert attribute(div, "id") == "my-drawer-title"
      assert text(div) == "some title"
    end

    test "with item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer">
          <:item class="is-rad">item</:item>
        </TestComponents.vertical_nav_section>
        """)

      assert attribute(html, ":root > div", "class") ==
               "vertical-nav-section-item is-rad"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer" data-test="hello">
          <:item>item</:item>
        </TestComponents.vertical_nav_section>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
