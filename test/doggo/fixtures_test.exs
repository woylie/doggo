defmodule Doggo.FixturesTest do
  @moduledoc """
  Keeps the markup fixtures in `test/fixtures` up-to-date.

  Run with `UPDATE_FIXTURES=1 mix test` after changing markup and review the
  diff.
  """

  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]

  alias Doggo.FixtureComponents
  alias Phoenix.LiveView.JS

  @moduletag :fixtures

  @fixture_dir Path.expand("../fixtures", __DIR__)

  test "accordion" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.accordion id="accordion">
        <:section title="Golden Retriever">Friendly.</:section>
        <:section title="Siberian Husky">Energetic.</:section>
        <:section title="Dachshund">Playful.</:section>
      </FixtureComponents.accordion>
      """,
      "accordion.html"
    )
  end

  test "action_bar" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.action_bar id="action-bar">
        <:item label="Edit" on_click={JS.push("edit")}>edit</:item>
        <:item label="Move" on_click={JS.push("move")}>move</:item>
        <:item label="Archive" on_click={JS.push("archive")}>archive</:item>
      </FixtureComponents.action_bar>
      """,
      "action_bar.html"
    )
  end

  test "alert" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.alert
        id="alert"
        title="Session expired"
        close_label="Dismiss"
        on_close={JS.push("dismiss")}
      >
        Sign in again to continue.
        <:icon>info-icon</:icon>
        <:close>close-icon</:close>
        <:action>sign-in-button</:action>
      </FixtureComponents.alert>
      """,
      "alert.html"
    )
  end

  test "alert_dialog" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.alert_dialog
        id="alert-dialog"
        on_cancel={JS.push("cancel")}
      >
        <:title>End session early?</:title>
        <p>Bella is making great progress today.</p>
        <:footer>end-session-button</:footer>
      </FixtureComponents.alert_dialog>
      """,
      "alert_dialog.html"
    )
  end

  test "app_bar" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.app_bar title="Dogs">
        <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
          menu-icon
        </:navigation>
        <:action label="Search" on_click={JS.push("search")}>search-icon</:action>
      </FixtureComponents.app_bar>
      """,
      "app_bar.html"
    )
  end

  test "avatar" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.avatar src="avatar.png" placeholder_src="fallback.png" />
      """,
      "avatar.html"
    )
  end

  test "badge" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.badge>8</FixtureComponents.badge>
      """,
      "badge.html"
    )
  end

  test "bottom_navigation" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.bottom_navigation current_value={:appointments} label="Main">
        <:item label="Profile" href="/profile" value={:profile}>profile-icon</:item>
        <:item label="Appointments" href="/appointments" value={:appointments}>
          appointments-icon
        </:item>
      </FixtureComponents.bottom_navigation>
      """,
      "bottom_navigation.html"
    )
  end

  test "box" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.box>
        <:title>Dog Facts</:title>
        <:banner>banner</:banner>
        <:action>action</:action>
        <p>Dogs are amazing.</p>
        <:footer>footer</:footer>
      </FixtureComponents.box>
      """,
      "box.html"
    )
  end

  test "breadcrumb" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.breadcrumb label="Breadcrumb">
        <:item patch="/categories">Categories</:item>
        <:item patch="/categories/1">Reviews</:item>
        <:item patch="/categories/1/articles/1">The Movie</:item>
      </FixtureComponents.breadcrumb>
      """,
      "breadcrumb.html"
    )
  end

  test "button" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.button>Confirm</FixtureComponents.button>
      """,
      "button.html"
    )
  end

  test "button_link" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.button_link patch="/confirm">
        Confirm
      </FixtureComponents.button_link>
      """,
      "button_link.html"
    )
  end

  test "callout" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.callout id="callout" title="Did you know?">
        <p>Dogs have three eyelids.</p>
        <:icon>info-icon</:icon>
        <:action><button>Learn More</button></:action>
      </FixtureComponents.callout>
      """,
      "callout.html"
    )
  end

  test "card" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.card>
        <:image>image</:image>
        <:header>
          <h2>Golden Retriever</h2>
        </:header>
        <:body>
          <p>Friendly and intelligent.</p>
        </:body>
        <:footer>footer</:footer>
      </FixtureComponents.card>
      """,
      "card.html"
    )
  end

  test "carousel" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.carousel id="carousel" label="Dog Fashion Show" pagination>
        <:pause label="Pause" resume_label="Resume">Pause</:pause>
        <:previous label="Previous slide">Previous</:previous>
        <:next label="Next slide">Next</:next>
        <:item label="1 of 3">Slide 1</:item>
        <:item label="2 of 3">Slide 2</:item>
        <:item label="3 of 3">Slide 3</:item>
      </FixtureComponents.carousel>
      """,
      "carousel.html"
    )
  end

  test "cluster" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.cluster>Hello</FixtureComponents.cluster>
      """,
      "cluster.html"
    )
  end

  test "combobox" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.combobox
        id="breed-selector"
        name="breed"
        list_label="Breeds"
        options={[
          {"Golden Retriever", "golden"},
          {"Siberian Husky", "husky"},
          "Dachshund"
        ]}
        value="husky"
      />
      """,
      "combobox.html"
    )
  end

  test "date" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.date value={~D[2023-12-27]} />
      """,
      "date.html"
    )
  end

  test "datetime" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.datetime value={~U[2023-12-27T18:30:21Z]} />
      """,
      "datetime.html"
    )
  end

  test "disclosure_button" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.disclosure_button controls="data-table">
        Data Table
      </FixtureComponents.disclosure_button>
      """,
      "disclosure_button.html"
    )
  end

  test "drawer" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.drawer>
        <:header>Doggo</:header>
        <:main>main</:main>
        <:footer>footer</:footer>
      </FixtureComponents.drawer>
      """,
      "drawer.html"
    )
  end

  test "fallback" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.fallback value={nil} accessibility_text="not available" />
      """,
      "fallback.html"
    )
  end

  test "field" do
    assigns = %{
      form: to_form(%{"breed" => "dachshund", "sterilized" => "true"})
    }

    assert_fixture(
      ~H"""
      <FixtureComponents.field field={@form[:name]} label="Name">
        <:description>The name on the tag.</:description>
      </FixtureComponents.field>
      <FixtureComponents.field field={@form[:bio]} label="Bio" type="textarea" />
      <FixtureComponents.field
        field={@form[:breed]}
        label="Breed"
        type="select"
        options={[{"Golden Retriever", "golden"}, {"Dachshund", "dachshund"}]}
      />
      <FixtureComponents.field
        field={@form[:sterilized]}
        label="Sterilized"
        type="checkbox"
      />
      <FixtureComponents.field
        field={@form[:vaccinated]}
        label="Vaccinated"
        type="switch"
      />
      <FixtureComponents.field
        field={@form[:tricks]}
        label="Tricks"
        type="checkbox-group"
        options={[{"Sit", "sit"}, {"Roll over", "roll-over"}]}
      />
      <FixtureComponents.field
        field={@form[:size]}
        label="Size"
        type="radio-group"
        options={[{"Small", "small"}, {"Large", "large"}]}
      />
      """,
      "field.html"
    )
  end

  test "field_group" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.field_group>fields</FixtureComponents.field_group>
      """,
      "field_group.html"
    )
  end

  test "frame" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.frame ratio="16:9">image</FixtureComponents.frame>
      """,
      "frame.html"
    )
  end

  test "icon" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.icon name="info" text="Info" />
      """,
      "icon.html"
    )
  end

  test "icon_sprite" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.icon_sprite name="edit" text="Edit" />
      """,
      "icon_sprite.html"
    )
  end

  test "image" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.image src="image.png" alt="A dog in a poncho">
        <:caption>A dog in a poncho.</:caption>
      </FixtureComponents.image>
      """,
      "image.html"
    )
  end

  test "menu" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.menu id="menu" label="Actions">
        <:item>
          <FixtureComponents.menu_item on_click={JS.push("copy")}>
            Copy
          </FixtureComponents.menu_item>
        </:item>
        <:item>
          <FixtureComponents.menu_item on_click={JS.push("copy-link")}>
            Copy link
          </FixtureComponents.menu_item>
        </:item>
        <:item>
          <FixtureComponents.menu_item on_click={JS.push("paste")}>
            Paste
          </FixtureComponents.menu_item>
        </:item>
        <:item>
          <FixtureComponents.menu id="submenu" label="Share">
            <:item>
              <FixtureComponents.menu_item on_click={JS.push("mail")}>
                Mail
              </FixtureComponents.menu_item>
            </:item>
          </FixtureComponents.menu>
        </:item>
        <:item role="separator" />
        <:item>
          <FixtureComponents.menu_item_checkbox on_click={JS.push("wrap")}>
            Wrap lines
          </FixtureComponents.menu_item_checkbox>
        </:item>
        <:item>
          <FixtureComponents.menu_item_radio_group label="Theme">
            <:item on_click={JS.push("light")} checked>Light</:item>
            <:item on_click={JS.push("dark")}>Dark</:item>
          </FixtureComponents.menu_item_radio_group>
        </:item>
      </FixtureComponents.menu>
      """,
      "menu.html"
    )
  end

  test "menu_bar" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.menu_bar id="menu-bar" label="Main">
        <:item>
          <FixtureComponents.menu_item on_click={JS.push("file")}>
            File
          </FixtureComponents.menu_item>
        </:item>
        <:item>
          <FixtureComponents.menu_item on_click={JS.push("edit")}>
            Edit
          </FixtureComponents.menu_item>
        </:item>
        <:item>
          <FixtureComponents.menu_item on_click={JS.push("view")}>
            View
          </FixtureComponents.menu_item>
        </:item>
      </FixtureComponents.menu_bar>
      """,
      "menu_bar.html"
    )
  end

  test "menu_button" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.menu_button id="actions-button" controls="actions-menu">
        Actions
      </FixtureComponents.menu_button>
      """,
      "menu_button.html"
    )
  end

  test "menu_group" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.menu_group label="Dog actions">
        <:item>feed</:item>
        <:item>walk</:item>
      </FixtureComponents.menu_group>
      """,
      "menu_group.html"
    )
  end

  test "menu_item" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.menu_item on_click={JS.push("copy")}>
        Copy
      </FixtureComponents.menu_item>
      """,
      "menu_item.html"
    )
  end

  test "menu_item_checkbox" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.menu_item_checkbox on_click={JS.push("wrap")}>
        Wrap lines
      </FixtureComponents.menu_item_checkbox>
      """,
      "menu_item_checkbox.html"
    )
  end

  test "menu_item_radio_group" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.menu_item_radio_group label="Theme">
        <:item on_click={JS.push("light")} checked>Light</:item>
        <:item on_click={JS.push("dark")}>Dark</:item>
      </FixtureComponents.menu_item_radio_group>
      """,
      "menu_item_radio_group.html"
    )
  end

  test "modal" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.modal id="modal">
        <:title>Edit dog</:title>
        <p>Dog form</p>
        <:footer>
          <button phx-click={Doggo.hide_modal("modal")}>Cancel</button>
        </:footer>
      </FixtureComponents.modal>
      """,
      "modal.html"
    )
  end

  test "navbar" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.navbar label="Main">
        <:brand>brand</:brand>
        content
      </FixtureComponents.navbar>
      """,
      "navbar.html"
    )
  end

  test "navbar_items" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.navbar_items>
        <:item>item</:item>
        <:item>another item</:item>
      </FixtureComponents.navbar_items>
      """,
      "navbar_items.html"
    )
  end

  test "page_header" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.page_header title="Dogs" subtitle="All of them">
        <:navigation label="Back" patch="/">back-icon</:navigation>
        <:action>action</:action>
      </FixtureComponents.page_header>
      """,
      "page_header.html"
    )
  end

  test "property_list" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.property_list>
        <:prop label="Name">George</:prop>
        <:prop label="Breed">Dachshund</:prop>
      </FixtureComponents.property_list>
      """,
      "property_list.html"
    )
  end

  test "radio_group" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.radio_group
        id="favorite-breed"
        name="favorite_breed"
        label="Favorite breed"
        value="dachshund"
        options={[{"Golden Retriever", "golden"}, {"Dachshund", "dachshund"}]}
      />
      """,
      "radio_group.html"
    )
  end

  test "skeleton" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.skeleton type="circle" />
      """,
      "skeleton.html"
    )
  end

  test "split_pane" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.split_pane
        id="split-pane"
        label="Sidebar"
        orientation="vertical"
        default_size={40}
        min_size={20}
        max_size={80}
      >
        <:primary>Navigation</:primary>
        <:secondary>Content</:secondary>
      </FixtureComponents.split_pane>
      """,
      "split_pane.html"
    )
  end

  test "stack" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.stack>Hello</FixtureComponents.stack>
      """,
      "stack.html"
    )
  end

  test "steps" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.steps current_step={1} label="Adoption process">
        <:step on_click={JS.push("go-to-step")}>Meet the dog</:step>
        <:step>Paperwork</:step>
        <:step>Take them home</:step>
      </FixtureComponents.steps>
      """,
      "steps.html"
    )
  end

  test "switch" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.switch label="Subscribe" checked />
      """,
      "switch.html"
    )
  end

  test "tab_navigation" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.tab_navigation current_value={:appointments} label="Sections">
        <:item patch="/profile" value={:profile}>Profile</:item>
        <:item patch="/appointments" value={:appointments}>Appointments</:item>
      </FixtureComponents.tab_navigation>
      """,
      "tab_navigation.html"
    )
  end

  test "table" do
    assigns = %{
      dogs: [%{id: 1, name: "George", breed: "Dachshund"}]
    }

    assert_fixture(
      ~H"""
      <FixtureComponents.table id="dogs" rows={@dogs} caption="Adoptable dogs">
        <:col :let={dog} label="Name">{dog.name}</:col>
        <:col :let={dog} label="Breed">{dog.breed}</:col>
        <:action :let={dog} label="Actions">
          <a href={"/dogs/#{dog.id}"}>Show</a>
        </:action>
        <:foot>1 dog</:foot>
      </FixtureComponents.table>
      """,
      "table.html"
    )
  end

  test "tabs" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.tabs id="tabs" label="Dog Breeds">
        <:panel label="Golden Retriever">Friendly.</:panel>
        <:panel label="Siberian Husky">Energetic.</:panel>
        <:panel label="Dachshund">Playful.</:panel>
      </FixtureComponents.tabs>
      """,
      "tabs.html"
    )
  end

  test "tag" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.tag>puppy</FixtureComponents.tag>
      """,
      "tag.html"
    )
  end

  test "time" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.time value={~T[18:30:21]} />
      """,
      "time.html"
    )
  end

  test "toggle_button" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.toggle_button on_click={JS.push("toggle-mute")}>
        Mute
      </FixtureComponents.toggle_button>
      """,
      "toggle_button.html"
    )
  end

  test "toolbar" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.toolbar id="toolbar" label="Actions for the dog">
        <div role="group">
          <button phx-click="feed-dog">Feed</button>
          <button phx-click="walk-dog" disabled>Walk</button>
        </div>
        <div role="group">
          <input type="text" name="note" aria-label="Note" />
          <button phx-click="teach-trick">Teach</button>
        </div>
      </FixtureComponents.toolbar>
      """,
      "toolbar.html"
    )
  end

  test "tooltip" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.tooltip id="tooltip">
        Labrador Retriever
        <:tooltip>A friendly breed.</:tooltip>
      </FixtureComponents.tooltip>
      """,
      "tooltip.html"
    )
  end

  test "tree" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.tree id="tree" label="Dog Breeds">
        <FixtureComponents.tree_item>
          Sporting
          <:items>
            <FixtureComponents.tree_item>
              Golden Retriever
            </FixtureComponents.tree_item>
            <FixtureComponents.tree_item>Irish Setter</FixtureComponents.tree_item>
          </:items>
        </FixtureComponents.tree_item>
        <FixtureComponents.tree_item expanded={false}>
          Working
          <:items>
            <FixtureComponents.tree_item>Boxer</FixtureComponents.tree_item>
            <FixtureComponents.tree_item>Great Dane</FixtureComponents.tree_item>
          </:items>
        </FixtureComponents.tree_item>
        <FixtureComponents.tree_item>Poodle</FixtureComponents.tree_item>
      </FixtureComponents.tree>
      """,
      "tree.html"
    )
  end

  test "tree_item" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.tree_item>
        Sporting
        <:items>
          <FixtureComponents.tree_item>Golden Retriever</FixtureComponents.tree_item>
        </:items>
      </FixtureComponents.tree_item>
      """,
      "tree_item.html"
    )
  end

  test "vertical_nav" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.vertical_nav id="main-nav" label="Main">
        <:title>Dogs</:title>
        <:item current_page>item</:item>
        <:item>another item</:item>
      </FixtureComponents.vertical_nav>
      """,
      "vertical_nav.html"
    )
  end

  test "vertical_nav_nested" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.vertical_nav_nested id="nested-nav">
        <:title>Breeds</:title>
        <:item current_page>item</:item>
        <:item>another item</:item>
      </FixtureComponents.vertical_nav_nested>
      """,
      "vertical_nav_nested.html"
    )
  end

  test "vertical_nav_section" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <FixtureComponents.vertical_nav_section id="nav-section">
        <:title>Dogs</:title>
        <:item>item</:item>
        <:item>another item</:item>
      </FixtureComponents.vertical_nav_section>
      """,
      "vertical_nav_section.html"
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

    expected = File.read!(path)

    if expected != html do
      flunk("""
      The fixture #{name} is out of date.

      To update the fixtures, run:

          UPDATE_FIXTURES=1 mix test

      #{verdict(expected, html)}

      #{diff(expected, html)}
      """)
    end
  end

  defp verdict(expected, actual) do
    if collapse(expected) == collapse(actual) do
      "The difference is whitespace only."
    else
      "The markup differs, not just the whitespace."
    end
  end

  defp collapse(html), do: String.replace(html, ~r/\s+/, " ")

  defp diff(expected, actual) do
    expected
    |> String.split("\n")
    |> List.myers_difference(String.split(actual, "\n"))
    |> Enum.flat_map(fn
      {:eq, _} -> []
      {:del, lines} -> Enum.map(lines, &"  - #{visible(&1)}")
      {:ins, lines} -> Enum.map(lines, &"  + #{visible(&1)}")
    end)
    |> Enum.take(40)
    |> Enum.join("\n")
  end

  defp visible(line) do
    line
    |> String.replace("\t", "\\t")
    |> String.replace(~r/ +$/, &String.duplicate("·", String.length(&1)))
  end
end
