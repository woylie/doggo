defmodule Doggo.IdUniquenessTest do
  @moduledoc """
  Renders two of every component that takes an `id` in one document and asserts
  that there are no duplicate IDs.

  `parse_heex/1` calls `Doggo.Accessibility.duplicate_ids/1`.
  """

  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS

  defmodule TestComponents do
    @moduledoc false
    use Doggo.Components
    use Phoenix.Component

    build_accordion()
    build_action_bar()
    build_alert()
    build_alert_dialog()
    build_callout()
    build_carousel()
    build_menu()
    build_menu_bar()
    build_menu_button()
    build_modal()
    build_radio_group()
    build_split_pane()
    build_table()
    build_tabs()
    build_toolbar()
    build_tooltip()
    build_tree()
    build_vertical_nav()
    build_vertical_nav_nested()
    build_vertical_nav_section()
  end

  test "two of each component in one document have no colliding ids" do
    assigns = %{}

    parse_heex(~H"""
    <%= for i <- [1, 2] do %>
      <TestComponents.accordion id={"accordion-#{i}"}>
        <:section title="Section">Content</:section>
      </TestComponents.accordion>
      <TestComponents.action_bar id={"action-bar-#{i}"}>
        <:item label="Edit" on_click={JS.push("edit")}>Edit</:item>
      </TestComponents.action_bar>
      <TestComponents.alert id={"alert-#{i}"} title="Title">
        Message
      </TestComponents.alert>
      <TestComponents.alert_dialog id={"alert-dialog-#{i}"}>
        <:title>Title</:title>
        Message
      </TestComponents.alert_dialog>
      <TestComponents.callout id={"callout-#{i}"} title="Title">
        Message
      </TestComponents.callout>
      <TestComponents.carousel id={"carousel-#{i}"} label="Dogs">
        <:previous label="Previous">‹</:previous>
        <:next label="Next">›</:next>
        <:item label="Slide">One</:item>
      </TestComponents.carousel>
      <TestComponents.menu id={"menu-#{i}"} label="Actions" hidden>
        <:item>Item</:item>
      </TestComponents.menu>
      <TestComponents.menu_bar id={"menu-bar-#{i}"} label="Main">
        <:item>Item</:item>
      </TestComponents.menu_bar>
      <TestComponents.menu_button controls={"menu-#{i}"} id={"menu-button-#{i}"}>Open</TestComponents.menu_button>
      <TestComponents.modal id={"modal-#{i}"}>
        <:title>Title</:title>
        Body
      </TestComponents.modal>
      <TestComponents.radio_group
        id={"radio-group-#{i}"}
        name={"breed-#{i}"}
        label="Breed"
        options={[{"Retriever", "retriever"}]}
      />
      <TestComponents.split_pane
        id={"split-pane-#{i}"}
        label="Sidebar"
        orientation="vertical"
        default_size={30}
      >
        <:primary>One</:primary>
        <:secondary>Two</:secondary>
      </TestComponents.split_pane>
      <TestComponents.table id={"table-#{i}"} rows={[%{id: 1, name: "Rex"}]}>
        <:col :let={r} label="Name">{r.name}</:col>
      </TestComponents.table>
      <TestComponents.tabs id={"tabs-#{i}"} label="Breeds">
        <:panel label="Panel">Content</:panel>
      </TestComponents.tabs>
      <TestComponents.toolbar id={"toolbar-#{i}"} label="Actions">
        Content
      </TestComponents.toolbar>
      <TestComponents.tooltip id={"tooltip-#{i}"}>
        Term
        <:tooltip>Help</:tooltip>
      </TestComponents.tooltip>
      <TestComponents.tree id={"tree-#{i}"} label="Files">Node</TestComponents.tree>
      <TestComponents.vertical_nav id={"vertical-nav-#{i}"} label="Main">
        <:item>Item</:item>
      </TestComponents.vertical_nav>
      <TestComponents.vertical_nav_nested id={"vertical-nav-nested-#{i}"}>
        <:item>Item</:item>
      </TestComponents.vertical_nav_nested>
      <TestComponents.vertical_nav_section id={"vertical-nav-section-#{i}"}>
        <:item>Item</:item>
      </TestComponents.vertical_nav_section>
    <% end %>
    """)
  end
end
