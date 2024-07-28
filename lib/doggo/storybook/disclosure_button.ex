defmodule Doggo.Storybook.DisclosureButton do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:cluster]

  def container, do: {:div, class: :container}

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          controls: "data-table-default"
        },
        slots: ["Learn More About Dog Breeds"],
        template: table("data-table-default", opts)
      }
    ]
  end

  def modifier_variation_group_template(name, opts) do
    table("data-table-#{name}", opts)
  end

  def modifier_variation_base(_id, name, value, _opts) do
    %{
      attributes: %{controls: "data-table-#{name}"},
      slots: [value || "nil"]
    }
  end

  defp table(id, _opts) do
    """
    <div>
      <div style="display: flex; flex-wrap: wrap; gap: 8px; align-items: center">
        <.psb-variation-group/>
      </div>
      <table id="#{id}" hidden>
        <tr>
          <th>Breed Name</th>
          <th>Origin</th>
          <th>Characteristic</th>
        </tr>
        <tr>
          <td>Labrador Retriever</td>
          <td>Canada</td>
          <td>Friendly and outgoing</td>
        </tr>
        <tr>
          <td>German Shepherd</td>
          <td>Germany</td>
          <td>Intelligent and versatile</td>
        </tr>
        <tr>
          <td>Beagle</td>
          <td>England</td>
          <td>Curious and merry</td>
        </tr>
      </table>
    </div>
    """
  end
end
