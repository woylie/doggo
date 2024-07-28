defmodule Doggo.Storybook.MenuItemRadioGroup do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu]

  def template(opts) do
    dependent_components = opts[:dependent_components]
    menu_fun = dependent_components[:menu]

    if menu_fun do
      """
      <.menu label="Actions">
        <:item>
          <.psb-variation/>
        </:item>
      </.menu>
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
          label: "Theme",
          on_click: Phoenix.LiveView.JS.dispatch("myapp:toggle-word-wrap")
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        label: "Theme",
        on_click: Phoenix.LiveView.JS.dispatch("myapp:toggle-word-wrap")
      },
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:item on_click={JS.dispatch("switch-theme-light")}>Light</:item>
      """,
      """
      <:item on_click={JS.dispatch("switch-theme-dark")}>Dark</:item>
      """
    ]
  end
end
