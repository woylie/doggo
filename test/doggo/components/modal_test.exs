defmodule Doggo.Components.ModalTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_modal()
  end

  describe "modal/1" do
    test "renders modal" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" on_cancel={JS.push("cancel")}>
          <:title>Edit dog</:title>
          dog-form
          <:footer>paw</:footer>
        </TestComponents.modal>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "id") == "pet-modal"
      assert attribute(dialog, "class") == "modal"
      assert attribute(dialog, "phx-hook") == "Doggo.Dialog"
      assert attribute(dialog, "closedby") == "any"
      assert attribute(dialog, "open") == nil
      assert attribute(dialog, "aria-modal") == nil

      # The browser owns the `open` attribute, so LiveView ignores it.
      assert attribute(dialog, "phx-mounted") =~ "ignore_attrs"
      refute attribute(dialog, "phx-mounted") =~ "doggo:open"

      a = find_one(html, ":root > section > header > button.modal-close")
      assert attribute(a, "type") == "button"
      assert attribute(a, "command") == "close"
      assert attribute(a, "commandfor") == "pet-modal"
      assert attribute(a, "aria-label") == "Close"
      assert text(a, "span") == "Close"

      h2 = find_one(html, ":root > section > header > h2")
      assert text(h2) == "Edit dog"

      assert text(html, "section > .modal-content") == "dog-form"
      assert text(html, "section > footer") == "paw"
    end

    test "omits close button without dismissable" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal
          id="pet-modal"
          on_cancel={JS.push("cancel")}
          dismissable={false}
        >
          <:title>Edit dog</:title>
          dog-form
          <:footer>paw</:footer>
        </TestComponents.modal>
        """)

      assert Floki.find(html, ".modal-close") == []
      assert attribute(html, "dialog:root", "closedby") == "none"
    end

    test "opens on mount with open" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" open>
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.modal>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "open") == nil
      assert attribute(dialog, "phx-mounted") =~ "doggo:open"
    end

    test "renders close slot in close button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" open>
          <:title>Edit dog</:title>
          dog-form
          <:close>X</:close>
        </TestComponents.modal>
        """)

      assert text(html, "button.modal-close") == "X"
    end

    test "renders close label as aria-label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" close_label="Cancel" open>
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.modal>
        """)

      assert attribute(html, "button.modal-close", "aria-label") == "Cancel"
    end

    test "pushes event name on cancel with on_cancel event name" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" on_cancel="cancel">
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.modal>
        """)

      ops =
        html
        |> attribute("dialog:root", "data-cancel")
        |> Phoenix.json_library().decode!()

      assert ["push", %{"event" => "cancel"}] in ops
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="pet-modal" data-test="hello">
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.modal>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
