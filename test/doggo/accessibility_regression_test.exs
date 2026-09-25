defmodule Doggo.AccessibilityRegressionTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc false
    use Doggo.Components
    use Phoenix.Component

    build_alert_dialog()
    build_button_link()
    build_modal()
    build_table()
  end

  describe "button_link/1" do
    test "renders no href if disabled" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_link disabled navigate="/pets">Pets</TestComponents.button_link>
        """)

      assert attribute(html, ":root", "href") == nil
      assert attribute(html, ":root", "aria-disabled") == "true"
      assert attribute(html, ":root", "role") == "link"
    end
  end

  describe "modal/1" do
    test "does not render aria-modal" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.modal id="modal">
          <:title>Title</:title>
          Body
        </TestComponents.modal>
        """)

      assert attribute(html, "dialog", "aria-modal") == nil
      assert attribute(html, "dialog", "open") == nil
    end
  end

  describe "alert_dialog/1" do
    test "does not render aria-modal" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.alert_dialog id="alert-dialog">
          <:title>Title</:title>
          Body
        </TestComponents.alert_dialog>
        """)

      assert attribute(html, "dialog", "aria-modal") == nil
      assert attribute(html, "dialog", "open") == nil
    end
  end

  describe "table/1" do
    test "does not apply row_click to action slot" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.table
          id="pets"
          rows={[%{id: 1, name: "Rex"}]}
          row_click={fn _ -> Phoenix.LiveView.JS.push("go") end}
        >
          <:col :let={p} label="Name">{p.name}</:col>
          <:action><a href="/pets/1">Show</a></:action>
        </TestComponents.table>
        """)

      [col, action] = Floki.find(html, "tbody td")
      assert attribute(col, "phx-click") != nil
      assert attribute(action, "phx-click") == nil
    end
  end
end
