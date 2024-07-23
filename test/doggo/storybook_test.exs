defmodule Doggo.StorybookTest do
  use ExUnit.Case
  use Phoenix.Component

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_accordion(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_action_bar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_alert(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_alert_dialog(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_app_bar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_avatar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_badge(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_bottom_navigation(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_box(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_breadcrumb(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_button(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_button_link(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_callout(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_card(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_carousel(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_cluster(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_combobox(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_date(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_datetime(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_disclosure_button(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_drawer(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_fab(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_fallback(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_field_description(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_field_errors(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_field_group(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_frame()
    build_icon(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_image(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_input()

    build_label(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_menu(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_menu_bar(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_menu_button(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_menu_group(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_menu_item(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_menu_item_checkbox(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_menu_item_radio_group(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_modal(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_navbar(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_page_header(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_property_list(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_radio_group(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_skeleton(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_split_pane(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_stack(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_steps(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_switch(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_tab_navigation(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_table(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_tabs(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_tag(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_time(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_toggle_button(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    build_toolbar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_tooltip(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    build_tree(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    build_vertical_nav(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )
  end

  for {name, info} <- TestComponents.__dog_components__() do
    component = Keyword.fetch!(info, :component)

    story_module =
      Module.concat([
        "Story",
        component |> Atom.to_string() |> Macro.camelize()
      ])

    @tag name: name
    @tag info: info
    @tag story_module: story_module
    test "generates storybook modules for #{name}", %{
      name: name,
      info: info,
      story_module: story_module
    } do
      defmodule unquote(story_module) do
        use PhoenixStorybook.Story, :component

        use Doggo.Storybook,
          module: Doggo.StorybookTest.TestComponents,
          name: unquote(name)
      end

      assert story_module.function()
      assert [_ | _] = story_module.variations()
    end
  end
end
