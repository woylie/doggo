defmodule DemoWeb.E2E.PatchComponents do
  @moduledoc false
  # The `components` of patch.spec.js: each one's `arrange` and `assert`.

  import DemoWeb.E2EHelpers

  alias Playwright.{Expect, Keyboard, Locator, Page}

  def components,
    do: [
      %{name: "modal", module: Modal, patches: patches_from_inside_dialog()},
      %{
        name: "alert_dialog",
        module: AlertDialog,
        patches: patches_from_inside_dialog()
      },
      %{name: "carousel", module: Carousel},
      %{name: "tabs", module: Tabs},
      %{name: "accordion", module: Accordion},
      %{name: "split_pane", module: SplitPane},
      %{name: "disclosure_button", module: DisclosureButton},
      %{name: "menu_button", module: MenuButton},
      %{name: "toggle_button", module: ToggleButton},
      %{name: "tree", module: Tree}
    ]

  def arrange(page, "modal") do
    page |> Page.get_by_role(:button, name: "Open modal") |> Locator.click!()
    Expect.to_be_visible!(Page.locator(page, "#test-modal"))
  end

  def arrange(page, "alert_dialog") do
    page
    |> Page.get_by_role(:button, name: "Open alert dialog")
    |> Locator.click!()

    Expect.to_be_visible!(Page.locator(page, "#test-alert-dialog"))
  end

  def arrange(page, "carousel") do
    page |> Page.get_by_role(:tab, name: "Slide 2") |> Locator.click!()

    Expect.to_have_attribute!(
      Page.get_by_role(page, :tab, name: "Slide 2"),
      "aria-selected",
      "true"
    )
  end

  def arrange(page, "tabs") do
    page |> Page.get_by_role(:tab, name: "Second") |> Locator.click!()
  end

  def arrange(page, "accordion") do
    page |> Page.get_by_role(:button, name: "Section one") |> Locator.click!()

    Expect.to_have_attribute!(
      Page.get_by_role(page, :button, name: "Section one"),
      "aria-expanded",
      "false"
    )
  end

  def arrange(page, "split_pane") do
    separator = Page.get_by_role(page, :separator)
    Locator.focus!(separator)
    page |> Page.keyboard() |> Keyboard.press!("ArrowRight")

    separator
    |> Expect.not_()
    |> Expect.to_have_attribute!("aria-valuenow", "30")
  end

  def arrange(page, "disclosure_button") do
    page
    |> Page.get_by_role(:button, name: "Toggle details")
    |> Locator.click!()

    Expect.to_be_visible!(Page.locator(page, "#test-disclosure"))
  end

  def arrange(page, "menu_button") do
    page |> Page.get_by_role(:button, name: "Actions") |> Locator.click!()
    page |> Page.get_by_role(:menuitem, name: "Foster") |> Locator.click!()
    Expect.to_be_hidden!(Page.locator(page, "#test-menu"))
  end

  def arrange(page, "toggle_button") do
    page |> Page.get_by_role(:button, name: "Toggle") |> Locator.click!()

    Expect.to_have_attribute!(
      Page.get_by_role(page, :button, name: "Toggle"),
      "aria-pressed",
      "true"
    )
  end

  def arrange(page, "tree") do
    page |> Page.locator("#tree-sporting > button") |> Locator.click!()

    Expect.to_have_attribute!(
      Page.locator(page, "#tree-sporting"),
      "aria-expanded",
      "false"
    )
  end

  def assert_state(page, "modal") do
    Expect.to_be_visible!(Page.locator(page, "#test-modal"))
    Expect.to_have_attribute!(Page.locator(page, "#test-modal"), "open", "")
  end

  def assert_state(page, "alert_dialog") do
    Expect.to_have_attribute!(
      Page.locator(page, "#test-alert-dialog"),
      "open",
      ""
    )
  end

  def assert_state(page, "carousel") do
    Expect.to_have_attribute!(
      Page.get_by_role(page, :tab, name: "Slide 2"),
      "aria-selected",
      "true"
    )
  end

  def assert_state(page, "tabs") do
    Expect.to_have_attribute!(
      Page.get_by_role(page, :tab, name: "Second"),
      "aria-selected",
      "true"
    )

    Expect.to_be_visible!(Page.get_by_text(page, "Second panel."))
  end

  def assert_state(page, "accordion") do
    Expect.to_have_attribute!(
      Page.get_by_role(page, :button, name: "Section one"),
      "aria-expanded",
      "false"
    )
  end

  def assert_state(page, "split_pane") do
    page
    |> Page.get_by_role(:separator)
    |> Expect.not_()
    |> Expect.to_have_attribute!("aria-valuenow", "30")
  end

  def assert_state(page, "disclosure_button") do
    Expect.to_be_visible!(Page.locator(page, "#test-disclosure"))

    Expect.to_have_attribute!(
      Page.get_by_role(page, :button, name: "Toggle details"),
      "aria-expanded",
      "true"
    )
  end

  def assert_state(page, "menu_button") do
    Expect.to_be_hidden!(Page.locator(page, "#test-menu"))

    Expect.to_have_attribute!(
      Page.get_by_role(page, :button, name: "Actions"),
      "aria-expanded",
      "false"
    )
  end

  def assert_state(page, "toggle_button") do
    Expect.to_have_attribute!(
      Page.get_by_role(page, :button, name: "Toggle"),
      "aria-pressed",
      "true"
    )
  end

  def assert_state(page, "tree") do
    Expect.to_have_attribute!(
      Page.locator(page, "#tree-sporting"),
      "aria-expanded",
      "false"
    )

    Expect.to_be_hidden!(Page.get_by_text(page, "Golden Retriever"))
  end
end

# A module per component, as a module per `test.describe(component.name)`, so
# they run in parallel.
for component <- DemoWeb.E2E.PatchComponents.components() do
  defmodule Module.concat(DemoWeb.E2E.PatchTest, component.module) do
    use DemoWeb.BrowserCase,
      async: true,
      parameterize: DemoWeb.BrowserCase.projects()

    alias DemoWeb.E2E.PatchComponents

    @component component

    describe @component.name do
      setup %{page: page} do
        open_harness(page)
        select_component(page, @component.name)
        :ok
      end

      for {kind, patch} <- @component[:patches] || patches() do
        @patch patch
        test "keeps its state through #{kind}", %{page: page} do
          PatchComponents.arrange(page, @component.name)
          @patch.(page)
          PatchComponents.assert_state(page, @component.name)
        end
      end

      if !@component[:patches] do
        test "keeps its state through a re-send while wrapped", %{page: page} do
          wrap_in_comprehension(page)
          PatchComponents.arrange(page, @component.name)

          resend(page)
          PatchComponents.assert_state(page, @component.name)
        end
      end
    end
  end
end
