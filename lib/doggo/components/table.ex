defmodule Doggo.Components.Table do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a simple table.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.table id="pets" rows={@pets}>
      <:col :let={p} label="name"><%= p.name %></:col>
      <:col :let={p} label="age"><%= p.age %></:col>
    </.table>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :developing,
      base_class: "table-container",
      modifiers: []
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :rows, :list,
        required: true,
        doc: "The list of items to be displayed in rows."

      attr :caption, :string,
        default: nil,
        doc: "Content for the `<caption>` element."

      attr :row_id, :any,
        default: nil,
        doc: """
        Overrides the default function that retrieves the row ID from a stream item.
        """

      attr :row_click, :any,
        default: nil,
        doc: """
        Sets the `phx-click` function attribute for each row `td`. Expects to be a
        function that receives a row item as an argument. This does not add the
        `phx-click` attribute to the `action` slot.

        Example:

        ```elixir
        row_click={&JS.navigate(~p"/users/\#{&1}")}
        ```
        """

      attr :row_item, :any,
        default: &Function.identity/1,
        doc: """
        This function is called on the row item before it is passed to the :col
        and :action slots.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :col,
        required: true,
        doc: """
        For each column to render, add one `<:col>` element.

        ```elixir
        <:col :let={pet} label="Name" field={:name} col_style="width: 20%;">
          <%= pet.name %>
        </:col>
        ```

        Any additional assigns will be added as attributes to the `<td>` elements.

        """ do
        attr :label, :any, doc: "The content for the header column."

        attr :col_attrs, :list,
          doc: """
          If set, a `<colgroup>` element is rendered and the attributes are added
          to the `<col>` element of the respective column.
          """
      end

      slot :action,
        doc: """
        The slot for showing user actions in the last table column. These columns
        do not receive the `row_click` attribute.


        ```elixir
        <:action :let={user}>
          <.link navigate={~p"/users/\#{user}"}>Show</.link>
        </:action>
        ```
        """ do
        attr :label, :string, doc: "The content for the header column."

        attr :col_attrs, :list,
          doc: """
          If set, a `<colgroup>` element is rendered and the attributes are added
          to the `<col>` element of the respective column.
          """
      end

      slot :foot,
        doc: """
        You can optionally add a `foot`. The inner block will be rendered inside
        a `tfoot` element.

            <Flop.Phoenix.table>
              <:foot>
                <tr><td>Total: <span class="total"><%= @total %></span></td></tr>
              </:foot>
            </Flop.Phoenix.table>
        """
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns,
          row_id: assigns.row_id || fn {id, _item} -> id end
        )
      end

    ~H"""
    <div class={@class} {@rest}>
      <table id={@id}>
        <caption :if={@caption}><%= @caption %></caption>
        <colgroup :if={
          Enum.any?(@col, & &1[:col_attrs]) or Enum.any?(@action, & &1[:col_attrs])
        }>
          <col :for={col <- @col} {col[:col_attrs] || []} />
          <col :for={action <- @action} {action[:col_attrs] || []} />
        </colgroup>
        <thead>
          <tr>
            <th :for={col <- @col}><%= col[:label] %></th>
            <th :for={action <- @action}><%= action[:label] %></th>
          </tr>
        </thead>
        <tbody
          id={@id <> "-tbody"}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
            <td :for={col <- @col} phx-click={@row_click && @row_click.(row)}>
              <%= render_slot(col, @row_item.(row)) %>
            </td>
            <td :for={action <- @action}>
              <%= render_slot(action, @row_item.(row)) %>
            </td>
          </tr>
        </tbody>
        <tfoot :if={@foot != []}><%= render_slot(@foot) %></tfoot>
      </table>
    </div>
    """
  end
end
