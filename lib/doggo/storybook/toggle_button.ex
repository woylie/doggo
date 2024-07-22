defmodule Doggo.Storybook.ToggleButton do
  @moduledoc false
  alias Phoenix.LiveView.JS
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          on_click: toggle_indicator(:default),
          pressed: false
        },
        slots: ["click me"],
        template: indicator_template(:default)
      },
      %Variation{
        id: :disabled,
        attributes: %{
          on_click: %Phoenix.LiveView.JS{},
          disabled: true
        },
        slots: ["click me"]
      }
    ]
  end

  def modifier_variation_group_template(name) do
    indicator_template(name)
  end

  def modifier_variation_base(_id, name, value) do
    %{
      attributes: %{
        :on_click => toggle_indicator(name),
        :pressed => false
      },
      slots: ["#{value || "nil"}"]
    }
  end

  defp indicator_template(id) do
    """
    <div>
      <.psb-variation-group/>
      <div id="indicator-on-#{id}" hidden>on</div>
      <div id="indicator-off-#{id}">off</div>
    </div>
    """
  end

  defp toggle_indicator(id) do
    %JS{}
    |> JS.toggle(to: "#indicator-on-#{id}")
    |> JS.toggle(to: "#indicator-off-#{id}")
  end
end
