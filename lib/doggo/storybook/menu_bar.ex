defmodule Doggo.Storybook.MenuBar do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu, :menu_button, :menu_item]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Main"
        },
        slots: slots(opts)
      }
    ]
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
        <.#{button_fun} controls="actions-menu" id="actions-button">
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

          <.#{menu_fun} id="actions-menu" labelledby="actions-button" hidden>
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
        <p>Please compile the <code>menu</code> and <code>menu_item</code> components to see a complete preview.</p>
        """
      ]
    end
  end
end
