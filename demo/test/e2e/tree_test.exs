defmodule DemoWeb.E2E.TreeTest do
  use DemoWeb.BrowserCase,
    async: true,
    parameterize: DemoWeb.BrowserCase.projects()

  defp expanded(page, id, value),
    do:
      Expect.to_have_attribute!(
        Page.locator(page, "##{id}"),
        "aria-expanded",
        value
      )

  describe "tree" do
    setup %{page: page} do
      open_harness(page)
      select_component(page, "tree")
      :ok
    end

    test "keeps an expanded branch expanded through a bump", %{page: page} do
      page |> Page.locator("#tree-working > button") |> Locator.click!()
      expanded(page, "tree-working", "true")

      bump(page)
      expanded(page, "tree-working", "true")
    end

    test "keeps a collapsed branch collapsed through a patch of a LiveComponent inside the tree",
         %{page: page} do
      page |> Page.locator("#tree-herding > button") |> Locator.click!()
      expanded(page, "tree-herding", "false")

      page
      |> Page.get_by_role(:button, name: "Update the component inside the tree")
      |> Locator.click!()

      Expect.to_be_attached!(
        Page.get_by_text(page, "Collie · component tick 1")
      )

      expanded(page, "tree-herding", "false")
    end

    test "keeps a collapsed branch collapsed through a patch of a LiveComponent around the tree",
         %{page: page} do
      page |> Page.locator("#tree-toy > button") |> Locator.click!()
      expanded(page, "tree-toy", "false")

      page
      |> Page.get_by_role(:button, name: "Update the component around the tree")
      |> Locator.click!()

      Expect.to_be_attached!(Page.get_by_text(page, "Pug · component tick 1"))
      expanded(page, "tree-toy", "false")
    end

    test "keeps the tab stop through a patch of a LiveComponent inside the tree",
         %{page: page} do
      page |> Page.locator("#tree-herding") |> Locator.focus!()

      Expect.to_have_attribute!(
        Page.locator(page, "#tree-herding"),
        "tabindex",
        "0"
      )

      page
      |> Page.get_by_role(:button, name: "Update the component inside the tree")
      |> Locator.click!()

      Expect.to_be_attached!(
        Page.get_by_text(page, "Collie · component tick 1")
      )

      Expect.to_have_attribute!(
        Page.locator(page, "#tree-herding"),
        "tabindex",
        "0"
      )

      Expect.to_have_count!(
        Page.locator(page, ~s(#test-tree [role="treeitem"][tabindex="0"])),
        1
      )
    end
  end
end
