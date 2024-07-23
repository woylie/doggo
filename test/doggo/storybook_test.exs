defmodule Doggo.StorybookTest do
  use ExUnit.Case
  use Phoenix.Component

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    accordion(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    action_bar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    alert(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    alert_dialog(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    app_bar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    avatar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    badge(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    bottom_navigation(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    box(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    breadcrumb(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    button(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    button_link(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    callout(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    card(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    carousel(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    cluster(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    combobox(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    date(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    datetime(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    disclosure_button(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    drawer(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    fab(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    fallback(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    field_description_builder(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    field_errors_builder(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    field_group_builder(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    frame_builder()
    icon(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    image(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    label_builder(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    menu(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    menu_bar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    menu_button(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    menu_group(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    menu_item(modifiers: [variant: [values: [nil, "yes"], default: nil]])

    menu_item_checkbox(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    menu_item_radio_group(
      modifiers: [variant: [values: [nil, "yes"], default: nil]]
    )

    modal(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    navbar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    page_header(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    property_list(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    radio_group(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    skeleton(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    split_pane(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    stack(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    steps(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    switch(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    tab_navigation(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    table(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    tabs(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    tag(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    time(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    toggle_button(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    toolbar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    tooltip(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    tree(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    vertical_nav(modifiers: [variant: [values: [nil, "yes"], default: nil]])
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
