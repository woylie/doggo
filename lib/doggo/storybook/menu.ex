defmodule Doggo.Storybook.Menu do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  @scope_id "menu-all-items"

  def dependent_components,
    do: [
      :menu_item,
      :menu_item_checkbox,
      :menu_item_radio_group,
      :menu_group
    ]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "actions-menu",
          label: "Actions"
        },
        slots: slots(opts)
      },
      %Variation{
        id: :all_item_types,
        note: all_item_note(opts),
        attributes: %{
          id: "all-items-menu",
          label: "View"
        },
        template: """
        <div id="#{@scope_id}">
          <.psb-variation/>
        </div>
        """,
        slots: all_item_slots(opts)
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, opts) do
    %{
      attributes: %{
        id: id,
        label: "Actions"
      },
      slots: slots(opts)
    }
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

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    if item_fun = dependent_components[:menu_item] do
      [
        """
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
        <:item role="separator" />
        <:item>
          <.#{item_fun} on_click={JS.push("dog-care-tips")}>
            Dog Care Tips
          </.#{item_fun}>
        </:item>
        """
      ]
    else
      [
        """
        <:item>
          <p>Please compile the <code>menu_item</code> component to see a complete preview.</p>
        </:item>
        """
      ]
    end
  end
end
