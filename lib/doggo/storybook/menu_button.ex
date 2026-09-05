defmodule Doggo.Storybook.MenuButton do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu, :menu_item]

  def template(opts) do
    dependent_components = opts[:dependent_components]
    menu_fun = dependent_components[:menu]
    item_fun = dependent_components[:menu_item]

    menu =
      if menu_fun && item_fun do
        """
        <.#{menu_fun} id="actions-menu" labelledby="actions-button" hidden>
          <:item>
            <.#{item_fun} on_click={JS.push("copy")}>Copy</.#{item_fun}>
          </:item>
          <:item>
            <.#{item_fun} on_click={JS.push("paste")}>Paste</.#{item_fun}>
          </:item>
          <:item role="separator"></:item>
          <:item>
            <.#{item_fun} on_click={JS.push("sort")}>Sort lines</.#{item_fun}>
          </:item>
        </.#{menu_fun}>
        """
      else
        """
        <p>Please compile the <code>menu</code> and <code>menu_item</code> components to see a complete preview.</p>
        """
      end

    """
    <div>
      <.psb-variation/>
      #{menu}
    </div>
    """
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          controls: "actions-menu",
          id: "actions-button"
        },
        slots: ["Actions"]
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, _opts) do
    %{
      attributes: %{
        id: id,
        controls: "actions-menu"
      },
      slots: ["Actions"]
    }
  end
end
