defmodule Doggo.Storybook.DisclosureButton do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          controls: "data-table-default"
        },
        slots: ["Data Table"],
        template: table("data-table-default")
      }
    ]
  end

  def modifier_variation_group_template(name, _opts) do
    table("data-table-#{name}")
  end

  def modifier_variation_base(_id, name, value, _opts) do
    %{
      attributes: %{controls: "data-table-#{name}"},
      slots: [value || "nil"]
    }
  end

  defp table(id) do
    """
    <div>
      <.psb-variation-group/>
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
