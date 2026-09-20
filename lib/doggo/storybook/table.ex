defmodule Doggo.Storybook.Table do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def layout, do: :one_column

  def template do
    """
    <div style="inline-size: 100%">
      <.psb-variation/>
    </div>
    """
  end

  def variations(_opts) do
    [
      %Variation{
        id: :basic,
        attributes: %{
          id: "pets",
          rows: [
            %{id: 1, name: "George", age: 8},
            %{id: 2, name: "Mary", age: 5}
          ]
        },
        slots: [
          """
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:col :let={p} label="Age"><%= p.age %></:col>
          """
        ]
      },
      %Variation{
        id: :actions,
        attributes: %{
          id: "pets",
          rows: [
            %{id: 1, name: "George", age: 8},
            %{id: 2, name: "Mary", age: 5}
          ]
        },
        slots: [
          """
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:col :let={p} label="Age"><%= p.age %></:col>
          <:action label="Actions">
            <.link>Edit</.link>
          </:action>
          """
        ]
      },
      %Variation{
        id: :caption,
        attributes: %{
          id: "pets",
          caption: "List of pets filtered by species",
          rows: [
            %{id: 1, name: "George", age: 8},
            %{id: 2, name: "Mary", age: 5}
          ]
        },
        slots: [
          """
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:col :let={p} label="Age"><%= p.age %></:col>
          """
        ]
      },
      %Variation{
        id: :foot,
        attributes: %{
          id: "pets",
          rows: [
            %{id: 1, name: "George", age: 8},
            %{id: 2, name: "Mary", age: 5}
          ]
        },
        slots: [
          """
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:col :let={p} label="Age"><%= p.age %></:col>
          <:foot>
            <tr>
              <td>Avg age</td>
              <td>7.5</td>
            </tr>
          </:foot>
          """
        ]
      },
      %Variation{
        id: :row_click,
        note: """
        `row_click` sets `phx-click` on each cell, which only pointer users can
        reach. Repeat the action inside the row, as the button in the last
        column does here, so that it is also reachable by keyboard.
        """,
        template: """
        <div style="inline-size: 100%">
          <.psb-variation/>
          <p id="table-row-clicked-1" hidden>You picked George.</p>
          <p id="table-row-clicked-2" hidden>You picked Mary.</p>
        </div>
        """,
        attributes: %{
          id: "pets",
          rows: [
            %{id: 1, name: "George", age: 8},
            %{id: 2, name: "Mary", age: 5}
          ],
          row_click: {:eval, ~s|&JS.toggle(to: "#table-row-clicked-\#{&1.id}")|}
        },
        slots: [
          """
          <:col :let={p} label="Name"><%= p.name %></:col>
          <:col :let={p} label="Age"><%= p.age %></:col>
          <:action :let={p} label="Actions">
            <button
              type="button"
              phx-click={JS.toggle(to: "#table-row-clicked-\#{p.id}")}
            >
              Pick
            </button>
          </:action>
          """
        ]
      },
      %Variation{
        id: :scrolling,
        note: """
        The wrapper is in the tab order so that the table can also be scrolled
        by keyboard. Set `label` to give it an accessible name, or set `caption`
        to use the name as both region name and table caption.
        """,
        attributes: %{
          id: "pets-wide",
          label: "Adoptable pets",
          rows: wide_rows()
        },
        slots: [wide_slots()]
      }
    ]
  end

  defp wide_rows do
    [
      %{
        id: 1,
        name: "George",
        breed: "Dachshund",
        age: 8,
        sex: "Male",
        weight: "9.2 kg",
        color: "Black and tan",
        chip: "981020012345678",
        vaccinated: "2026-03-14",
        neutered: "Yes",
        shelter: "Bergedorf Animal Shelter",
        arrived: "2025-11-02",
        owner: "Katrin Dinkelschrot",
        email: "katrin.dinkelschrot@example.com",
        phone: "+49 40 123456",
        licence: "HH-2025-004871",
        status: "Available"
      },
      %{
        id: 2,
        name: "Mary",
        breed: "Golden Retriever",
        age: 5,
        sex: "Female",
        weight: "28.6 kg",
        color: "Cream",
        chip: "981020087654321",
        vaccinated: "2026-01-27",
        neutered: "No",
        shelter: "Altona Rescue Centre",
        arrived: "2026-02-19",
        owner: "Hendrik Vollmerhausen",
        email: "hendrik.vollmerhausen@example.com",
        phone: "+49 40 654321",
        licence: "HH-2026-001294",
        status: "Reserved"
      }
    ]
  end

  defp wide_slots do
    """
    <:col :let={p} label="Name"><%= p.name %></:col>
    <:col :let={p} label="Breed"><%= p.breed %></:col>
    <:col :let={p} label="Age"><%= p.age %></:col>
    <:col :let={p} label="Sex"><%= p.sex %></:col>
    <:col :let={p} label="Weight"><%= p.weight %></:col>
    <:col :let={p} label="Colour"><%= p.color %></:col>
    <:col :let={p} label="Microchip"><%= p.chip %></:col>
    <:col :let={p} label="Vaccinated"><%= p.vaccinated %></:col>
    <:col :let={p} label="Neutered"><%= p.neutered %></:col>
    <:col :let={p} label="Shelter"><%= p.shelter %></:col>
    <:col :let={p} label="Arrived"><%= p.arrived %></:col>
    <:col :let={p} label="Owner"><%= p.owner %></:col>
    <:col :let={p} label="Email"><%= p.email %></:col>
    <:col :let={p} label="Phone"><%= p.phone %></:col>
    <:col :let={p} label="Licence"><%= p.licence %></:col>
    <:col :let={p} label="Status"><%= p.status %></:col>
    """
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        rows: [
          %{id: 1, name: "George", age: 8},
          %{id: 2, name: "Mary", age: 5}
        ]
      },
      slots: [
        """
        <:col :let={p} label="Name"><%= p.name %></:col>
        <:col :let={p} label="Age"><%= p.age %></:col>
        """
      ]
    }
  end
end
