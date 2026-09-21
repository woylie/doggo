defmodule Doggo.Storybook.MenuItemRadioGroup do
  @moduledoc false

  alias PhoenixStorybook.Stories.Variation

  @scope_id "theme-options"

  def dependent_components, do: [:menu]

  def template(opts) do
    dependent_components = opts[:dependent_components]
    menu_fun = dependent_components[:menu]

    if menu_fun do
      """
      <div id="#{@scope_id}">
        <.#{menu_fun} id="menu-:variation_id" label="Actions">
          <:item>
            <.psb-variation/>
          </:item>
        </.#{menu_fun}>
      </div>
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
        attributes: %{label: "Theme"},
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{label: "Theme"},
      slots: slots()
    }
  end

  defp slots do
    [
      choice("light", "Light", " checked"),
      choice("dark", "Dark", "")
    ]
  end

  defp choice(theme, label, checked) do
    """
    <:item#{checked}
      on_click={
        JS.set_attribute({"aria-checked", "false"},
          to: "##{@scope_id} [role='menuitemradio']"
        )
        |> JS.set_attribute({"aria-checked", "true"})
        |> JS.dispatch("switch-theme-#{theme}")
      }
    >#{label}</:item>
    """
  end
end
