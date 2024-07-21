defmodule Doggo.Storybook.DisclosureButton do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <div>
      <.psb-variation/>
      <table id="data-table" hidden>
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

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          controls: "data-table"
        },
        slots: ["Data Table"]
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, :controls => "data-table"},
      slots: ["Data Table"]
    }
  end
end
