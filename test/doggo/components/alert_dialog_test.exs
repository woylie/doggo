defmodule Doggo.Components.AlertDialogTest do
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

    build_alert_dialog()
  end

  describe "alert_dialog/1" do
    test "default" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert_dialog id="pet-alert" on_cancel={JS.push("cancel")}>
          <:title>Edit dog</:title>
          dog-form
          <:footer>paw</:footer>
        </TestComponents.alert_dialog>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "role") == "alertdialog"
      assert attribute(dialog, "id") == "pet-alert"
      assert attribute(dialog, "class") == "alert-dialog"
      assert attribute(dialog, "phx-hook") == "Doggo.Dialog"
      assert attribute(dialog, "aria-describedby") == "pet-alert-content"
      assert attribute(dialog, "open") == nil
      assert attribute(dialog, "aria-modal") == nil

      # An alert dialog is not dismissable by default.
      assert attribute(dialog, "closedby") == "none"

      # The browser owns the `open` attribute, so LiveView ignores it.
      assert attribute(dialog, "phx-mounted") =~ "ignore_attrs"
      refute attribute(dialog, "phx-mounted") =~ "doggo:open"

      assert Floki.find(html, ".alert-dialog-close") == []

      h2 = find_one(html, ":root > div > section > header > h2")
      assert text(h2) == "Edit dog"

      assert text(html, "section > .alert-dialog-content") == "dog-form"
      assert text(html, "section > footer") == "paw"
    end

    test "dismissable" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert_dialog
          id="pet-alert"
          on_cancel={JS.push("cancel")}
          dismissable
        >
          <:title>Edit dog</:title>
          dog-form
          <:footer>paw</:footer>
        </TestComponents.alert_dialog>
        """)

      a =
        find_one(
          html,
          ":root > div > section > header > button.alert-dialog-close"
        )

      assert attribute(html, "dialog:root", "closedby") == "any"

      assert attribute(a, "type") == "button"
      assert attribute(a, "command") == "close"
      assert attribute(a, "commandfor") == "pet-alert"
      assert attribute(a, "aria-label") == "Close"
      assert text(a, "span") == "Close"
    end

    test "opened" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert_dialog id="pet-alert" open>
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.alert_dialog>
        """)

      dialog = find_one(html, "dialog:root")
      assert attribute(dialog, "open") == nil
      assert attribute(dialog, "phx-mounted") =~ "doggo:open"
    end

    test "with close slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert_dialog id="pet-alert" dismissable>
          <:title>Edit dog</:title>
          dog-form
          <:close>X</:close>
        </TestComponents.alert_dialog>
        """)

      assert text(html, "button.alert-dialog-close") == "X"
    end

    test "with close label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert_dialog id="pet-alert" close_label="Cancel" dismissable>
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.alert_dialog>
        """)

      assert attribute(html, "button.alert-dialog-close", "aria-label") ==
               "Cancel"
    end

    test "with global attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert_dialog id="pet-alert" data-test="hello">
          <:title>Edit dog</:title>
          dog-form
        </TestComponents.alert_dialog>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
