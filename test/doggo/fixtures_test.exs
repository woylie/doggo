defmodule Doggo.FixturesTest do
  @moduledoc """
  Keeps the markup fixtures the JavaScript hook tests load in step with the
  components.

  Run with `UPDATE_FIXTURES=1 mix test` after changing the markup of a
  component that ships a hook.
  """

  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]

  alias Doggo.HookComponents
  alias Phoenix.LiveView.JS

  @moduletag :fixtures

  @fixture_dir Path.expand("../../assets/test/fixtures", __DIR__)

  test "tabs fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.tabs id="tabs" label="Dog Breeds">
        <:panel label="Golden Retriever">Friendly.</:panel>
        <:panel label="Siberian Husky">Energetic.</:panel>
        <:panel label="Dachshund">Playful.</:panel>
      </HookComponents.tabs>
      """,
      "tabs.html"
    )
  end

  test "carousel fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.carousel id="carousel" label="Dog Fashion Show" pagination>
        <:pause label="Pause" resume_label="Resume">Pause</:pause>
        <:previous label="Previous slide">Previous</:previous>
        <:next label="Next slide">Next</:next>
        <:item label="1 of 3">Slide 1</:item>
        <:item label="2 of 3">Slide 2</:item>
        <:item label="3 of 3">Slide 3</:item>
      </HookComponents.carousel>
      """,
      "carousel.html"
    )
  end

  test "toolbar fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.toolbar id="toolbar" label="Actions for the dog">
        <div role="group">
          <button phx-click="feed-dog">Feed</button>
          <button phx-click="walk-dog" disabled>Walk</button>
        </div>
        <div role="group">
          <input type="text" name="note" aria-label="Note" />
          <button phx-click="teach-trick">Teach</button>
        </div>
      </HookComponents.toolbar>
      """,
      "toolbar.html"
    )
  end

  test "action_bar fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.action_bar id="action-bar">
        <:item label="Edit" on_click={JS.push("edit")}>edit</:item>
        <:item label="Move" on_click={JS.push("move")}>move</:item>
        <:item label="Archive" on_click={JS.push("archive")}>archive</:item>
      </HookComponents.action_bar>
      """,
      "action_bar.html"
    )
  end

  test "tooltip fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.tooltip id="tooltip">
        Labrador Retriever
        <:tooltip>A friendly breed.</:tooltip>
      </HookComponents.tooltip>
      """,
      "tooltip.html"
    )
  end

  test "accordion fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.accordion id="accordion">
        <:section title="Golden Retriever">Friendly.</:section>
        <:section title="Siberian Husky">Energetic.</:section>
        <:section title="Dachshund">Playful.</:section>
      </HookComponents.accordion>
      """,
      "accordion.html"
    )
  end

  test "menu fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.menu id="menu" label="Actions">
        <:item>
          <HookComponents.menu_item on_click={JS.push("copy")}>
            Copy
          </HookComponents.menu_item>
        </:item>
        <:item>
          <HookComponents.menu_item on_click={JS.push("copy-link")}>
            Copy link
          </HookComponents.menu_item>
        </:item>
        <:item>
          <HookComponents.menu_item on_click={JS.push("paste")}>
            Paste
          </HookComponents.menu_item>
        </:item>
        <:item>
          <HookComponents.menu id="submenu" label="Share">
            <:item>
              <HookComponents.menu_item on_click={JS.push("mail")}>
                Mail
              </HookComponents.menu_item>
            </:item>
          </HookComponents.menu>
        </:item>
        <:item role="separator" />
        <:item>
          <HookComponents.menu_item_checkbox on_click={JS.push("wrap")}>
            Wrap lines
          </HookComponents.menu_item_checkbox>
        </:item>
        <:item>
          <HookComponents.menu_item_radio_group label="Theme">
            <:item on_click={JS.push("light")} checked>Light</:item>
            <:item on_click={JS.push("dark")}>Dark</:item>
          </HookComponents.menu_item_radio_group>
        </:item>
      </HookComponents.menu>
      """,
      "menu.html"
    )
  end

  test "menu_bar fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.menu_bar id="menu-bar" label="Main">
        <:item>
          <HookComponents.menu_item on_click={JS.push("file")}>
            File
          </HookComponents.menu_item>
        </:item>
        <:item>
          <HookComponents.menu_item on_click={JS.push("edit")}>
            Edit
          </HookComponents.menu_item>
        </:item>
        <:item>
          <HookComponents.menu_item on_click={JS.push("view")}>
            View
          </HookComponents.menu_item>
        </:item>
      </HookComponents.menu_bar>
      """,
      "menu_bar.html"
    )
  end

  test "tree fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.tree id="tree" label="Dog Breeds">
        <HookComponents.tree_item>
          Sporting
          <:items>
            <HookComponents.tree_item>Golden Retriever</HookComponents.tree_item>
            <HookComponents.tree_item>Irish Setter</HookComponents.tree_item>
          </:items>
        </HookComponents.tree_item>
        <HookComponents.tree_item expanded={false}>
          Working
          <:items>
            <HookComponents.tree_item>Boxer</HookComponents.tree_item>
            <HookComponents.tree_item>Great Dane</HookComponents.tree_item>
          </:items>
        </HookComponents.tree_item>
        <HookComponents.tree_item>Poodle</HookComponents.tree_item>
      </HookComponents.tree>
      """,
      "tree.html"
    )
  end

  test "modal fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.modal id="modal">
        <:title>Edit dog</:title>
        <p>Dog form</p>
        <:footer>
          <button phx-click={Doggo.hide_modal("modal")}>Cancel</button>
        </:footer>
      </HookComponents.modal>
      """,
      "modal.html"
    )
  end

  test "split_pane fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.split_pane
        id="split-pane"
        label="Sidebar"
        orientation="vertical"
        default_size={40}
        min_size={20}
        max_size={80}
      >
        <:primary>Navigation</:primary>
        <:secondary>Content</:secondary>
      </HookComponents.split_pane>
      """,
      "split_pane.html"
    )
  end

  defp assert_fixture(rendered, name) do
    html = rendered_to_string(rendered)
    path = Path.join(@fixture_dir, name)

    if System.get_env("UPDATE_FIXTURES") do
      File.mkdir_p!(@fixture_dir)
      File.write!(path, html)
    end

    assert File.exists?(path), """
    The fixture #{name} does not exist.

    Create it by running the suite with UPDATE_FIXTURES set:

        UPDATE_FIXTURES=1 mix test
    """

    assert File.read!(path) == html, """
    The fixture #{name} is out of date, so the JavaScript hook tests are running
    against markup this component no longer emits.

    Update it and check whether the hook still works:

        UPDATE_FIXTURES=1 mix test
    """
  end
end
