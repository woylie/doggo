defmodule Doggo.Storybook.MenuItem do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu]

  def template(opts) do
    dependent_components = opts[:dependent_components]
    menu_fun = dependent_components[:menu]

    if menu_fun do
      """
      <.#{menu_fun} label="Actions">
        <:item>
          <.psb-variation/>
        </:item>
      </.#{menu_fun}>
      """
    else
      """
      <p>Please compile the <code>menu</code> component to see a complete preview.</p>
      """
    end
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          on_click: Phoenix.LiveView.JS.dispatch("myapp:copy")
        },
        slots: ["Copy"]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        on_click: Phoenix.LiveView.JS.dispatch("myapp:copy")
      },
      slots: ["Copy"]
    }
  end
end
