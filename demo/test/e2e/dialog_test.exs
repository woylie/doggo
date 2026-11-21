defmodule DemoWeb.E2E.DialogTest do
  # describe "modal"
  use DemoWeb.BrowserCase,
    async: true,
    parameterize: DemoWeb.BrowserCase.projects()

  defp modal?(dialog),
    do: Locator.evaluate!(dialog, ~s|(el) => el.matches(":modal")|)

  @moves [
    %{
      name: "in a keyed comprehension",
      opener: "Open the reorder modal",
      dialog: "#test-modal-reorder",
      control: "Reorder from inside",
      moved: :reorder_moved
    },
    %{
      name: "in a live component",
      opener: "Open the modal in a component",
      dialog: "#test-modal-in-component",
      control: "Toggle the note from inside",
      moved: :note_moved
    }
  ]

  defp moved(page, :reorder_moved) do
    Expect.to_have_id!(
      page |> Page.locator("[id^=reorder-]") |> Locator.first(),
      "reorder-dialog"
    )
  end

  defp moved(page, :note_moved) do
    Expect.to_be_visible!(Page.locator(page, "#note"))
  end

  for move <- @moves do
    @move move
    test "stays modal when a patch moves it #{move.name}", %{page: page} do
      move = @move
      open_harness(page)
      opener = Page.get_by_role(page, :button, name: move.opener)
      dialog = Page.locator(page, move.dialog)
      control = Locator.get_by_role(dialog, :button, name: move.control)

      Locator.press!(opener, "Enter")
      Expect.to_be_visible!(dialog)
      Locator.press!(control, "Enter")
      moved(page, move.moved)

      Expect.poll!(fn -> modal?(dialog) end, &assert(&1 == true))
      Expect.to_be_focused!(control)

      page |> Page.keyboard() |> Keyboard.press!("Escape")
      Expect.to_be_hidden!(dialog)
      Expect.to_be_focused!(opener)
    end
  end

  test "keeps a dialog opened over it on top when a patch moves it", %{
    page: page
  } do
    open_harness(page)
    lower = Page.locator(page, "#test-modal-reorder")
    upper = Page.locator(page, "#test-modal-in-component")

    control =
      Locator.get_by_role(upper, :button, name: "Toggle the note from inside")

    page
    |> Page.get_by_role(:button, name: "Open the reorder modal")
    |> Locator.press!("Enter")

    Locator.evaluate!(
      upper,
      ~s|(el) => el.dispatchEvent(new CustomEvent("doggo:open", { bubbles: true }))|
    )

    Expect.poll!(fn -> modal?(upper) end, &assert(&1 == true))
    Locator.focus!(control)

    Locator.evaluate!(lower, """
    (el) => {
      const item = el.parentElement;
      item.parentElement.append(item);
    }
    """)

    Expect.poll!(fn -> modal?(lower) end, &assert(&1 == true))
    Expect.to_be_focused!(control)
    box = Locator.bounding_box!(control)

    hit =
      Page.evaluate!(
        page,
        ~s|({ x, y }) => document.elementFromPoint(x, y)?.closest("dialog")?.id|,
        %{x: box.x + box.width / 2, y: box.y + box.height / 2}
      )

    assert hit == "test-modal-in-component"

    page |> Page.keyboard() |> Keyboard.press!("Escape")
    Expect.to_be_hidden!(upper)
    page |> Page.keyboard() |> Keyboard.press!("Escape")
    Expect.to_be_hidden!(lower)

    Expect.to_be_focused!(
      Page.get_by_role(page, :button, name: "Open the reorder modal")
    )
  end

  test "leaves a dialog opened with show() non-modal", %{page: page} do
    open_harness(page)
    dialog = Page.locator(page, "#test-modal-reorder")

    page
    |> Page.get_by_role(:button, name: "Open the reorder modal")
    |> Locator.click!()

    Expect.poll!(fn -> modal?(dialog) end, &assert(&1 == true))

    Locator.evaluate!(dialog, """
    async (el) => {
      el.close();
      el.show();
      document.body.append(document.createElement("p"));
      await new Promise((resolve) => setTimeout(resolve));
      document.body.append(document.createElement("p"));
      await new Promise((resolve) => setTimeout(resolve));
    }
    """)

    Expect.to_be_visible!(dialog)
    Expect.poll!(fn -> modal?(dialog) end, &assert(&1 == false))
  end
end
