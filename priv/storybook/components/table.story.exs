defmodule Storybook.Components.Table do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.table/1

  def variations do
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
          <:col :let={p} label="name"><%= p.name %></:col>
          <:col :let={p} label="age"><%= p.age %></:col>
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
          <:col :let={p} label="name"><%= p.name %></:col>
          <:col :let={p} label="age"><%= p.age %></:col>
          <:action :let={p}>
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
          <:col :let={p} label="name"><%= p.name %></:col>
          <:col :let={p} label="age"><%= p.age %></:col>
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
          <:col :let={p} label="name"><%= p.name %></:col>
          <:col :let={p} label="age"><%= p.age %></:col>
          <:foot>
            <tr>
              <td>Avg age</td>
              <td>7.5</td>
            </tr>
          </:foot>
          """
        ]
      }
    ]
  end
end
