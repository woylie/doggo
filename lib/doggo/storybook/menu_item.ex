defmodule Doggo.Storybook.MenuItem do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <Doggo.menu label="Actions">
      <:item>
        <.psb-variation/>
      </:item>
    </Doggo.menu>
    """
  end

  def variations do
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

  def modifier_variation_base(_id, _name, _value) do
    %{
      attributes: %{
        on_click: Phoenix.LiveView.JS.dispatch("myapp:copy")
      },
      slots: ["Copy"]
    }
  end
end
