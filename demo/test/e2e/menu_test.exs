defmodule DemoWeb.E2E.MenuButtonTest do
  # describe "menu_button"
  use DemoWeb.BrowserCase,
    async: true,
    parameterize: DemoWeb.BrowserCase.projects()

  defp button(page), do: Page.get_by_role(page, :button, name: "Actions")
  defp menu(page), do: Page.locator(page, "#test-menu")

  defp wrap_lines(page),
    do:
      page
      |> menu()
      |> Locator.locator(~s([role="menuitemcheckbox"]), has_text: "Wrap lines")

  setup %{page: page} do
    open_harness(page)
    select_component(page, "menu_button")
    :ok
  end

  test "closes the menu and focuses the button on Enter", %{page: page} do
    Locator.click!(button(page))
    Expect.to_be_visible!(menu(page))

    page |> Page.get_by_role(:menuitem, name: "Adopt") |> Locator.focus!()
    page |> Page.keyboard() |> Keyboard.press!("Enter")

    Expect.to_have_text!(Page.locator(page, "#chosen"), "Chosen: Adopt")
    Expect.to_be_hidden!(menu(page))
    Expect.to_have_attribute!(button(page), "aria-expanded", "false")
    Expect.to_be_focused!(button(page))
  end

  test "closes the menu and focuses the button on Space", %{page: page} do
    Locator.click!(button(page))
    Expect.to_be_visible!(menu(page))

    page |> Page.get_by_role(:menuitem, name: "Adopt") |> Locator.focus!()
    page |> Page.keyboard() |> Keyboard.press!(" ")

    Expect.to_have_text!(Page.locator(page, "#chosen"), "Chosen: Adopt")
    Expect.to_be_hidden!(menu(page))
    Expect.to_have_attribute!(button(page), "aria-expanded", "false")
    Expect.to_be_focused!(button(page))
  end

  test "lets a click-away binding fire when an item is chosen", %{page: page} do
    Locator.click!(button(page))
    page |> Page.get_by_role(:menuitem, name: "Foster") |> Locator.click!()
    Expect.to_have_text!(Page.locator(page, "#chosen"), "Chosen: Foster")

    Expect.to_have_text!(Page.locator(page, "#clicked-away"), "Clicked away: 2")
  end

  test "opens the menu again after an item is chosen", %{page: page} do
    Locator.click!(button(page))
    page |> Page.get_by_role(:menuitem, name: "Foster") |> Locator.click!()
    Expect.to_have_text!(Page.locator(page, "#chosen"), "Chosen: Foster")

    Locator.click!(button(page))

    Expect.to_be_visible!(menu(page))
    Expect.to_have_attribute!(button(page), "aria-expanded", "true")
  end

  describe "when opened with the keyboard" do
    test "keeps the menu open when a checkbox item is toggled", %{page: page} do
      Locator.press!(button(page), "ArrowDown")
      Expect.to_be_visible!(menu(page))

      item = wrap_lines(page)
      Locator.focus!(item)
      page |> Page.keyboard() |> Keyboard.press!("Enter")
      Expect.to_have_attribute!(item, "aria-checked", "true")

      Expect.to_be_visible!(menu(page))
      Expect.to_have_attribute!(button(page), "aria-expanded", "true")
    end

    test "keeps the menu open if Escape closed it before", %{page: page} do
      Locator.click!(button(page))
      page |> Page.keyboard() |> Keyboard.press!("Escape")
      Expect.to_be_hidden!(menu(page))

      Locator.press!(button(page), "ArrowDown")
      Expect.to_be_visible!(menu(page))

      item = wrap_lines(page)
      Locator.focus!(item)
      page |> Page.keyboard() |> Keyboard.press!("Enter")
      Expect.to_have_attribute!(item, "aria-checked", "true")

      Expect.to_be_visible!(menu(page))
      Expect.to_have_attribute!(button(page), "aria-expanded", "true")
      Expect.to_be_focused!(item)
    end
  end

  test "keeps the menu open when a checkbox item is toggled", %{page: page} do
    Locator.click!(button(page))
    Locator.click!(wrap_lines(page))
    Expect.to_have_attribute!(wrap_lines(page), "aria-checked", "true")

    Expect.to_be_visible!(menu(page))
  end
end
