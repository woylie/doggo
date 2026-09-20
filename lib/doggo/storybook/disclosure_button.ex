defmodule Doggo.Storybook.DisclosureButton do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def container, do: {:div, class: "container"}

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          controls: "data-table-default"
        },
        slots: ["Learn More About Dog Breeds"],
        template: variation_template("data-table-default", opts)
      }
    ]
  end

  def modifier_variation_group_template(name, opts) do
    variation_group_template("data-table-#{name}", opts)
  end

  def modifier_variation_base(_id, name, value, _opts) do
    %{
      attributes: %{controls: "data-table-#{name}"},
      slots: [to_string(value || "nil")]
    }
  end

  defp variation_template(id, _opts) do
    """
    <div style="display: flex; flex-direction: column; gap: 1.5rem">
      <div>
        <.psb-variation-group/>
      </div>
      #{content(id)}
    </div>
    """
  end

  defp variation_group_template(id, _opts) do
    """
    <div  style="display: flex; flex-direction: column; gap: 1.5rem">
      <div style="display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center">
        <.psb-variation-group/>
      </div>
      #{content(id)}
    </div>
    """
  end

  defp content(id) do
    """
    <p id="#{id}" hidden>
      Labrador Retrievers come from Canada and are friendly and outgoing.
    </p>
    """
  end
end
