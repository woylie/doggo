defmodule Doggo.Components.CarouselTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_carousel()
  end

  describe "carousel/1" do
    test "renders carousel" do
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

      items =
        find_one(
          html,
          ":root > .carousel-inner > .carousel-items-container  > .carousel-items"
        )

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

    test "renders previous and next buttons" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:previous label="Previous Slide">Previous</:previous>
          <:next label="Next Slide">Next</:next>
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
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

    test "renders pagination as tab list" do
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

      div = find_one(html, ".carousel-controls > .carousel-pagination")
      assert attribute(div, "role") == "tablist"
      assert attribute(div, "aria-label") == "スライド"

      assert button = find_one(div, "button:first-child")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "tab"
      assert attribute(button, "id") == "dog-carousel-tab-1"
      assert attribute(button, "aria-selected") == "true"
      assert attribute(button, "tabindex") == nil
      assert attribute(button, "aria-label") == "1 of 2"
      assert attribute(button, "aria-controls") == "dog-carousel-item-1"

      assert button = find_one(div, "button:last-child")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "tab"
      assert attribute(button, "id") == "dog-carousel-tab-2"
      assert attribute(button, "aria-selected") == "false"
      assert attribute(button, "tabindex") == "-1"
      assert attribute(button, "aria-label") == "2 of 2"
      assert attribute(button, "aria-controls") == "dog-carousel-item-2"

      div = find_one(html, ".carousel-items > .carousel-item:first-child")
      assert attribute(div, "role") == "tabpanel"
      assert attribute(div, "aria-labelledby") == "dog-carousel-tab-1"
      assert attribute(div, "aria-roledescription") == "slide"
      assert attribute(div, "aria-label") == nil
    end

    test "numbers pagination labels for slides without labels" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel
          id="dog-carousel"
          label="Dog Carousel"
          pagination_slide_label={&"スライド#{&1}"}
          pagination
        >
          <:item>A</:item>
          <:item>B</:item>
        </TestComponents.carousel>
        """)

      div = find_one(html, ".carousel-pagination")

      assert button = find_one(div, "button:first-child")
      assert attribute(button, "aria-label") == "スライド1"

      assert button = find_one(div, "button:last-child")
      assert attribute(button, "aria-label") == "スライド2"
    end

    test "renders slides as groups without pagination" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:item label="1 of 1">A</:item>
        </TestComponents.carousel>
        """)

      div = find_one(html, ".carousel-items > .carousel-item")
      assert attribute(div, "role") == "group"
      assert attribute(div, "aria-label") == "1 of 1"
      assert attribute(div, "aria-labelledby") == nil
    end

    test "renders labelledby as aria-labelledby" do
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

    test "renders role descriptions" do
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

    test "loops by default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:previous label="Previous Slide">Previous</:previous>
          <:next label="Next Slide">Next</:next>
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
        </TestComponents.carousel>
        """)

      assert attribute(html, "section:root", "data-loop") == "data-loop"
      assert attribute(html, "button.carousel-previous", "disabled") == nil
      assert attribute(html, "button.carousel-next", "disabled") == nil
    end

    test "disables previous button without loop" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel" loop={false}>
          <:previous label="Previous Slide">Previous</:previous>
          <:next label="Next Slide">Next</:next>
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
        </TestComponents.carousel>
        """)

      assert attribute(html, "section:root", "data-loop") == nil

      # the first item shows, so there is nothing before it
      assert attribute(html, "button.carousel-previous", "disabled") ==
               "disabled"

      assert attribute(html, "button.carousel-next", "disabled") == nil
    end

    test "omits controls and rotation with single item" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel" pagination>
          <:pause label="Pause" resume_label="Resume">Pause</:pause>
          <:previous label="Previous Slide">Previous</:previous>
          <:next label="Next Slide">Next</:next>
          <:item label="1 of 1">A</:item>
        </TestComponents.carousel>
        """)

      assert [] = Floki.find(html, ".carousel-controls")
      assert [] = Floki.find(html, ".carousel-pagination")
      assert attribute(html, "section:root", "data-rotation-interval-ms") == nil

      div = find_one(html, ".carousel-items")
      assert attribute(div, "aria-live") == "polite"

      div = find_one(html, ".carousel-item")
      assert attribute(div, "role") == "group"
      assert attribute(div, "aria-label") == "1 of 1"
      assert attribute(div, "aria-labelledby") == nil
    end

    test "renders pause button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:pause label="Pause" resume_label="Resume">Pause</:pause>
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
        </TestComponents.carousel>
        """)

      button = find_one(html, ".carousel-controls > button.carousel-pause")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-controls") == "dog-carousel-items"
      assert attribute(button, "aria-label") == "Pause"
      assert attribute(button, "data-pause-label") == "Pause"
      assert attribute(button, "data-resume-label") == "Resume"
      assert text(button) == "Pause"

      div =
        find_one(
          html,
          ":root > .carousel-inner > .carousel-items-container > .carousel-items"
        )

      assert attribute(div, "aria-live") == "off"
    end

    test "renders rotation interval with pause control" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel
          id="dog-carousel"
          label="Dog Carousel"
          rotation_interval_ms={8000}
        >
          <:pause label="Pause" resume_label="Resume">Pause</:pause>
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
        </TestComponents.carousel>
        """)

      assert attribute(html, "section:root", "data-rotation-interval-ms") ==
               "8000"
    end

    test "renders default rotation interval" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:pause label="Pause" resume_label="Resume">Pause</:pause>
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
        </TestComponents.carousel>
        """)

      assert attribute(html, "section:root", "data-rotation-interval-ms") ==
               "5000"
    end

    test "omits rotation interval without pause control" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel
          id="dog-carousel"
          label="Dog Carousel"
          rotation_interval_ms={8000}
        >
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
        </TestComponents.carousel>
        """)

      assert attribute(html, "section:root", "data-rotation-interval-ms") == nil
    end

    test "renders default labels for pause control without labels" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:pause>Pause</:pause>
          <:item label="1 of 2"></:item>
          <:item label="2 of 2"></:item>
        </TestComponents.carousel>
        """)

      button = find_one(html, "button.carousel-pause")
      assert attribute(button, "aria-label") == "Pause slide show"
      assert attribute(button, "data-pause-label") == "Pause slide show"
      assert attribute(button, "data-resume-label") == "Resume slide show"
    end

    test "omits pause button without pause control" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.carousel id="dog-carousel" label="Dog Carousel">
          <:item label="1 of 1"></:item>
        </TestComponents.carousel>
        """)

      assert [] = Floki.find(html, ".carousel-pause")

      div =
        find_one(
          html,
          ":root > .carousel-inner > .carousel-items-container > .carousel-items"
        )

      assert attribute(div, "aria-live") == "polite"
    end

    test "renders global attributes" do
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
end
