defmodule DemoWeb.E2E.CarouselTest do
  use DemoWeb.BrowserCase,
    async: true,
    parameterize: DemoWeb.BrowserCase.projects()

  setup %{page: page} do
    open_harness(page)
    select_component(page, "carousel")
    :ok
  end

  test "scrolls the slides by keyboard", %{page: page} do
    container = Page.locator(page, "#test-carousel .carousel-items-container")
    Locator.focus!(container)

    before = Locator.evaluate!(container, "(el) => el.scrollLeft")
    page |> Page.keyboard() |> Keyboard.press!("ArrowRight")

    Expect.poll!(
      fn -> Locator.evaluate!(container, "(el) => el.scrollLeft") end,
      &assert(&1 > before)
    )
  end

  test "marks the focused scroll container", %{page: page} do
    container = Page.locator(page, "#test-carousel .carousel-items-container")
    Locator.focus!(container)

    outline_style =
      Locator.evaluate!(container, "(el) => getComputedStyle(el).outlineStyle")

    assert outline_style == "solid"
  end
end
