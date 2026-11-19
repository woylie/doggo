defmodule DemoWeb.E2EHelpers do
  @moduledoc """
  Helpers of the end-to-end tests.
  """

  alias Playwright.Expect
  alias Playwright.Locator
  alias Playwright.Page

  defp tick(page), do: Page.locator(page, "#tick")

  def open_harness(page) do
    Page.goto!(page, "/patch-test")
    Page.wait_for_function!(page, "() => window.liveSocket?.isConnected()")
  end

  def select_component(page, value) do
    Expect.to_pass!(
      fn ->
        page |> Page.locator("#component") |> Locator.select_option!(value)

        page
        |> Page.get_by_role(:heading, level: 2)
        |> Expect.to_have_text!(value, timeout: 1000)
      end,
      timeout: 15_000
    )
  end

  def patches,
    do: [
      bump: &__MODULE__.bump/1,
      bumpFromOutside: &__MODULE__.bump_from_outside/1,
      roundTrip: &__MODULE__.round_trip/1
    ]

  def bump(page) do
    before = String.to_integer(Locator.inner_text!(tick(page)))
    page |> Page.get_by_role(:button, name: "Bump") |> Locator.click!()
    Expect.to_have_text!(tick(page), to_string(before + 1))
  end

  def bump_from_outside(page) do
    page
    |> Page.get_by_role(:button, name: "Move tick outside")
    |> Locator.click!()

    Expect.to_be_visible!(
      Page.get_by_text(page, "tick inside components false")
    )

    bump(page)
  end

  def round_trip(page) do
    page |> Page.get_by_role(:button, name: "Round trip") |> Locator.click!()
    Page.wait_for_timeout!(page, 100)
  end

  def patches_from_inside_dialog,
    do: [
      bumpFromInside: &__MODULE__.bump_from_inside/1,
      resendFromInside: &__MODULE__.resend_from_inside/1
    ]

  def bump_from_inside(page) do
    before = String.to_integer(Locator.inner_text!(tick(page)))

    page
    |> Page.get_by_role(:button, name: "Bump from inside")
    |> Locator.click!()

    Expect.to_have_text!(tick(page), to_string(before + 1))
  end

  def resend_from_inside(page) do
    page
    |> Page.get_by_role(:button, name: "Re-send from inside")
    |> Locator.click!()
  end

  def wrap_in_comprehension(page) do
    page
    |> Page.get_by_role(:button, name: "Wrap in a comprehension")
    |> Locator.click!()

    Expect.to_be_visible!(Page.get_by_text(page, "wrapped true"))
  end

  def resend(page) do
    page |> Page.get_by_role(:button, name: "Re-send") |> Locator.click!()
    Expect.to_be_visible!(Page.get_by_text(page, "re-sends 1"))
  end

  @axe_path Path.expand("../../assets/node_modules/axe-core/axe.min.js", __DIR__)

  # `new AxeBuilder({ page }).include(selector).analyze()` from
  # @axe-core/playwright: evaluate axe-core (a devDependency of `assets`) in the
  # page, as AxeBuilder does, and run it. The
  # storybook has no iframes, so there are no partial results to merge.
  def axe_violations(page, include) do
    Page.evaluate!(page, File.read!(@axe_path))

    %{"violations" => violations} =
      Page.evaluate!(page, "(context) => axe.run(context)", %{
        include: [include]
      })

    violations
  end
end
