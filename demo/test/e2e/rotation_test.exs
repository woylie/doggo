defmodule DemoWeb.E2E.RotationTest do
  use DemoWeb.BrowserCase,
    async: true,
    parameterize: DemoWeb.BrowserCase.projects()

  alias Playwright.Clock

  defp dot(page, n), do: Page.get_by_role(page, :tab, name: "Slide #{n}")

  defp selected(page, n),
    do: Expect.to_have_attribute!(dot(page, n), "aria-selected", "true")

  setup %{page: page} do
    page |> Page.clock() |> Clock.install!()
    open_harness(page)
    select_component(page, "carousel")
    :ok
  end

  test "rotates to the next slide on its own", %{page: page} do
    selected(page, 1)

    page |> Page.clock() |> Clock.run_for!(5000)
    selected(page, 2)

    page |> Page.clock() |> Clock.run_for!(5000)
    selected(page, 3)
  end

  test "wraps to the first slide", %{page: page} do
    page |> Page.clock() |> Clock.run_for!(15_000)
    selected(page, 1)
  end

  test "stops and resumes with the pause control", %{page: page} do
    control = Page.get_by_role(page, :button, name: ~r/slide show/)

    Locator.click!(control)
    page |> Page.clock() |> Clock.run_for!(15_000)
    selected(page, 1)

    Locator.click!(control)
    # Pointer is still on the button; rotation does not resume under it
    page |> Page.mouse() |> Mouse.move!(0, 0)
    page |> Page.clock() |> Clock.run_for!(5000)
    selected(page, 2)
  end
end
