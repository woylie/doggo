defmodule Doggo.Components.ImageTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_image()
  end

  describe "image/1" do
    test "renders image" do
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

    test "renders width and height" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" width={300} height={200} />
        """)

      img = find_one(html, ":root > .image-frame > img")
      assert attribute(img, "width") == "300"
      assert attribute(img, "height") == "200"
    end

    test "renders loading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" loading="eager" />
        """)

      assert attribute(html, "img", "loading") == "eager"
    end

    test "renders ratio as data attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" ratio="3:2" />
        """)

      assert attribute(html, ":root", "class") == "image"
      assert attribute(html, ":root .image-frame", "data-numerator") == "3"
      assert attribute(html, ":root .image-frame", "data-denominator") == "2"
    end

    test "renders caption" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text">
          <:caption>some caption</:caption>
        </TestComponents.image>
        """)

      assert text(html, ":root > figcaption") == "some caption"
    end

    test "renders srcset from string" do
      srcset = "images/image-1x.jpg 1x, images/image-2x.jpg 2x"
      assigns = %{srcset: srcset}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" srcset={@srcset} />
        """)

      assert attribute(html, "img", "srcset") == srcset
    end

    test "renders srcset from map" do
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

    test "renders sizes" do
      sizes = "(max-width: 30em) 20em"
      assigns = %{sizes: sizes}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" sizes={@sizes} />
        """)

      assert attribute(html, "img", "sizes") == sizes
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.image src="image.png" alt="some text" data-test="hello" />
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
