defmodule Storybook.Components.DisclosureButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.disclosure_button/1

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
end
