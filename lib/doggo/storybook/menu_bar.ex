defmodule Doggo.Storybook.MenuBar do
  @moduledoc false

  import Doggo.Storybook.Shared

  alias PhoenixStorybook.Stories.Variation

  @scope_id "menu-bar-all-items"

  def dependent_components,
    do: [
      :menu,
      :menu_button,
      :menu_item,
      :menu_item_checkbox,
      :menu_item_radio_group,
      :menu_group
    ]

  def template do
    """
    <div style="inline-size: 100%">
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Main"
        },
        slots: slots(opts)
      },
      %Variation{
        id: :all_item_types,
        note: all_item_note(opts),
        attributes: %{label: "Main"},
        template: """
        <div id="#{@scope_id}" style="inline-size: 100%">
          <.psb-variation/>
        </div>
        """,
        slots: all_item_slots(opts)
      }
    ]
  end

  @item_components [
    :menu_item,
    :menu_group,
    :menu_item_checkbox,
    :menu_item_radio_group
  ]

  defp all_item_note(opts) do
    missing_components_note(opts[:dependent_components], @item_components)
  end

  defp all_item_slots(opts) do
    dependent_components = opts[:dependent_components]
    item_fun = dependent_components[:menu_item]
    group_fun = dependent_components[:menu_group]
    checkbox_fun = dependent_components[:menu_item_checkbox]
    radio_fun = dependent_components[:menu_item_radio_group]

    group =
      if group_fun && item_fun do
        """
        <:item>
          <.#{group_fun} label="Profiles">
            <:item>
              <.#{item_fun} on_click={JS.push("view-dog-profiles")}>
                View Dog Profiles
              </.#{item_fun}>
            </:item>
            <:item>
              <.#{item_fun} on_click={JS.push("add-dog-profile")}>
                Add Dog Profile
              </.#{item_fun}>
            </:item>
          </.#{group_fun}>
        </:item>
        <:item role="separator" />
        """
      end

    checkbox =
      if checkbox_fun do
        """
        <:item>
          <.#{checkbox_fun} on_click={JS.toggle_attribute({"aria-checked", "true", "false"})}>
            Word wrap
          </.#{checkbox_fun}>
        </:item>
        <:item role="separator" />
        """
      end

    radio_group =
      if radio_fun do
        """
        <:item>
          <.#{radio_fun} label="Theme">
            <:item checked on_click={#{theme_click("light")}}>Light</:item>
            <:item on_click={#{theme_click("dark")}}>Dark</:item>
          </.#{radio_fun}>
        </:item>
        """
      end

    case Enum.reject([group, checkbox, radio_group], &is_nil/1) do
      [] -> slots(opts)
      parts -> [Enum.join(parts)]
    end
  end

  defp theme_click(theme) do
    ~s|JS.set_attribute({"aria-checked", "false"}, | <>
      ~s|to: "##{@scope_id} [role='menuitemradio']") | <>
      ~s'|> JS.set_attribute({"aria-checked", "true"}) ' <>
      ~s'|> JS.dispatch("switch-theme-#{theme}")'
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{label: "Main"},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]
    menu_fun = dependent_components[:menu]
    item_fun = dependent_components[:menu_item]
    button_fun = dependent_components[:menu_button]

    button =
      if button_fun do
        """
        <.#{button_fun} controls="menu-bar-actions-menu" id="menu-bar-actions-button" menuitem>
          Actions
        </.#{button_fun}>
        """
      else
        """
        <p>Please compile the <code>menu_button</code> component to see a complete preview.</p>
        """
      end

    if menu_fun && item_fun do
      [
        """
        <:item>
          #{button}

          <.#{menu_fun} id="menu-bar-actions-menu" labelledby="menu-bar-actions-button" hidden>
            <:item>
              <.#{item_fun} on_click={JS.push("view-dog-profiles")}>
                View Dog Profiles
              </.#{item_fun}>
            </:item>
            <:item>
              <.#{item_fun} on_click={JS.push("add-dog-profile")}>
                Add Dog Profile
              </.#{item_fun}>
            </:item>
            <:item>
              <.#{item_fun} on_click={JS.push("dog-care-tips")}>
                Dog Care Tips
              </.#{item_fun}>
            </:item>
          </.#{menu_fun}>
        </:item>
        <:item role="separator"></:item>
        <:item>
          <.#{item_fun} on_click={JS.dispatch("myapp:help")}>
            Help
          </.#{item_fun}>
        </:item>
        """
      ]
    else
      [
        """
        <:item>
          <p>Please compile the <code>menu</code> and <code>menu_item</code> components to see a complete preview.</p>
        </:item>
        """
      ]
    end
  end
end
