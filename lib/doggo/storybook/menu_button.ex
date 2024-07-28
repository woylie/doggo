defmodule Doggo.Storybook.MenuButton do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu]

  def template(opts) do
    dependent_components = opts[:dependent_components]
    menu_fun = dependent_components[:menu]

    menu =
      if menu_fun do
        """
        <.#{menu_fun} id="actions-menu" labelledby="actions-button" hidden>
          <:item>Copy</:item>
          <:item>Paste</:item>
          <:item role="separator"></:item>
          <:item>Sort lines</:item>
        </.#{menu_fun}>
        """
      else
        """
        <p>Please compile the <code>menu</code> component to see a complete preview.</p>
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
