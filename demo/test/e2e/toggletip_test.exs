defmodule DemoWeb.E2E.ToggletipTest do
  # describe "toggletip"
  use DemoWeb.BrowserCase,
    async: true,
    parameterize: DemoWeb.BrowserCase.projects()

  alias Playwright.CDPSession

  defp button(page),
    do: Page.get_by_role(page, :button, name: "About the adoption fee")

  defp panel(page), do: Page.locator(page, "#test-toggletip-panel")

  defp open?(page),
    do: Locator.evaluate!(panel(page), ~s|(el) => el.matches(":popover-open")|)

  defp expanded(page) do
    session = page |> Page.context() |> BrowserContext.new_cdp_session!(page)

    %{"nodes" => nodes} =
      CDPSession.send!(session, "Accessibility.getFullAXTree")

    node =
      Enum.find(nodes, fn n ->
        get_in(n, ["role", "value"]) == "button" &&
          get_in(n, ["name", "value"]) == "About the adoption fee"
      end)

    property = Enum.find(node["properties"] || [], &(&1["name"] == "expanded"))
    get_in(property || %{}, ["value", "value"])
  end

  setup %{page: page} do
    open_harness(page)
    select_component(page, "toggletip")
    :ok
  end

  test "reports the panel's state as expanded", %{
    page: page,
    browser_name: browser_name
  } do
    # test.skip(browserName !== "chromium", "reads the tree through CDP")
    if browser_name == :chromium do
      assert expanded(page) == false
      Locator.click!(button(page))
      Expect.to_be_visible!(panel(page))
      assert expanded(page) == true
    end
  end

  test "announces the panel's text when it opens", %{page: page} do
    Locator.click!(button(page))

    Expect.to_contain_text!(
      Page.locator(page, "#test-toggletip [role='status']"),
      "The fee covers vaccinations and a microchip."
    )

    Locator.click!(button(page))

    Expect.to_have_text!(
      Page.locator(page, "#test-toggletip [role='status']"),
      ""
    )
  end

  test "returns focus to the button on Escape from the panel", %{
    page: page,
    browser_name: browser_name
  } do
    Locator.focus!(button(page))
    page |> Page.keyboard() |> Keyboard.press!("Enter")
    Expect.to_be_visible!(panel(page))

    page
    |> Page.keyboard()
    |> Keyboard.press!(if browser_name == :webkit, do: "Alt+Tab", else: "Tab")

    Expect.to_be_focused!(
      Page.get_by_role(page, :link, name: "How fees are used")
    )

    page |> Page.keyboard() |> Keyboard.press!("Escape")
    assert open?(page) == false
    Expect.to_be_focused!(button(page))
  end

  test "closes on a click outside", %{page: page} do
    Locator.click!(button(page))
    Expect.to_be_visible!(panel(page))
    page |> Page.get_by_role(:heading, name: "toggletip") |> Locator.click!()
    assert open?(page) == false
  end

  test "places the panel next to the button", %{page: page} do
    Locator.click!(button(page))
    Expect.to_be_visible!(panel(page))
    b = Locator.bounding_box!(button(page))
    p = Locator.bounding_box!(panel(page))
    assert abs(p.y - (b.y + b.height)) < 40
    assert abs(p.x - b.x) < 40
  end

  defp push(page, event) do
    Page.evaluate!(
      page,
      """
      (event) =>
        window.liveSocket.execJS(
          document.body,
          JSON.stringify([["push", { event }]]),
        )
      """,
      event
    )
  end

  test "stays open through a patch", %{page: page} do
    Locator.click!(button(page))
    Expect.to_be_visible!(panel(page))
    before = page |> Page.locator("#tick") |> Locator.inner_text!()

    push(page, "bump")

    page
    |> Page.locator("#tick")
    |> Expect.not_()
    |> Expect.to_have_text!(before)

    assert open?(page) == true
  end

  test "stays open through a re-send while wrapped", %{page: page} do
    wrap_in_comprehension(page)
    Locator.click!(button(page))
    Expect.to_be_visible!(panel(page))

    push(page, "resend")

    Expect.to_be_visible!(Page.get_by_text(page, "re-sends 1"))
    assert open?(page) == true
  end

  test "closes on Escape inside a dialog without closing the dialog", %{
    page: page
  } do
    select_component(page, "modal")
    page |> Page.get_by_role(:button, name: "Open modal") |> Locator.click!()
    Expect.to_be_visible!(Page.locator(page, "#test-modal"))

    inner = Page.get_by_role(page, :button, name: "About the modal")
    Locator.click!(inner)
    Expect.to_be_visible!(Page.locator(page, "#test-modal-toggletip-panel"))

    page |> Page.keyboard() |> Keyboard.press!("Escape")

    assert page
           |> Page.locator("#test-modal-toggletip-panel")
           |> Locator.evaluate!(~s|(el) => el.matches(":popover-open")|) ==
             false

    Expect.to_have_attribute!(Page.locator(page, "#test-modal"), "open", "")
  end
end
