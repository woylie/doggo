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
    <.table id="pets" rows={@pets} caption="Pets">
      <:col :let={p} label="name"><%= p.name %></:col>
      <:col :let={p} label="age"><%= p.age %></:col>
    </.table>
    ```

    ## Row actions

    `row_click` sets `phx-click` on each cell, which reaches pointer users only.
    Where you use it, repeat the action as a link or button inside the row, so
    that it can also be reached by keyboard.

    ```heex
    <.table
      id="pets"
      rows={@pets}
      caption="Pets"
      row_click={&JS.navigate(~p"/pets/\#{&1}")}
    >
      <:col :let={p} label="name">
        <.link navigate={~p"/pets/\#{p}"}><%= p.name %></.link>
      </:col>
    </.table>
    ```

    ## Scroll container

    The `div` around the table has `tabindex="0"`, so that a table that is wider
    than its container can be scrolled using the keyboard. This assumes that you
    make the container scrollable:

    ```css
    .table-container {
      overflow-x: auto;
    }
    ```

    Set `caption` or `label` to name the container, which is then exposed as a
    region. A blank value counts as unset.

    If the table fits its container, or sits in another scroll container, set
    `scrollable={false}`. The wrapper then has no `tabindex`, no role and no
    name, and does not add a useless tab stop.
    """
  end

  @impl true
  def css_path do
    "components/table.css"
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
  def own_attributes, do: ["aria-labelledby": nil, role: nil, tabindex: nil]

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true

      attr :rows, :list,
        required: true,
        doc: "The list of items to be displayed in rows."

      attr :caption, :string,
        default: nil,
        doc: "Content for the `<caption>` element."

      attr :label, :string,
        default: nil,
        doc: """
        Names the scroll container, which is in the tab order so that the table
        can be scrolled by keyboard.

        If not set, the caption is used to name the container. A scrollable
        container needs one of the two.
        """

      attr :scrollable, :boolean,
        default: true,
        doc: """
        Puts the container in the tab order and exposes it as a named region,
        so that a table wider than its container can be scrolled by keyboard.
        Set it to `false` for a table that fits its container.
        """

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

        This is a pointer convenience only. A `td` is not focusable, has no
        interactive role and takes no key events, so the action is unavailable
        to keyboard and screen reader users. Every action reachable through
        `row_click` must therefore also be reachable from a link or button
        inside the row, in a `:col` or `:action` slot.

        Example:

        ```elixir
        <.table id="users" rows={@users} row_click={&JS.navigate(~p"/users/\#{&1}")}>
          <:col :let={user} label="Name">
            <.link navigate={~p"/users/\#{user}"}>{user.name}</.link>
          </:col>
        </.table>
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
  def init_block(opts, _extra) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      require Doggo

      Doggo.diagnostic do
        unquote(__MODULE__).ensure_name!(var!(assigns), unquote(name))
      end
    end
  end

  @doc false
  def ensure_name!(%{scrollable: true, label: label, caption: caption}, name) do
    if Doggo.named?(label) or Doggo.named?(caption) do
      :ok
    else
      raise ArgumentError, """
      missing name for scrollable #{name}

      The container of a scrollable table is in the tab order, so it needs a
      name. Set `caption` or `label`, or set `scrollable={false}` for a table
      that fits its container.

          label: #{inspect(label)}
          caption: #{inspect(caption)}
      """
    end
  end

  def ensure_name!(_assigns, _name), do: :ok

  @impl true
  def render(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns,
          row_id: assigns.row_id || fn {id, _item} -> id end
        )
      end

    ~H"""
    <div
      class={@class}
      tabindex={@scrollable && "0"}
      role={
        @scrollable && (Doggo.named?(@label) || Doggo.named?(@caption)) &&
          "region"
      }
      aria-label={@scrollable && Doggo.named?(@label) && @label}
      aria-labelledby={
        @scrollable && !Doggo.named?(@label) && Doggo.named?(@caption) &&
          "#{@id}-caption"
      }
      {@data_attrs}
      {@rest}
    >
      <table id={@id}>
        <caption :if={@caption} id={"#{@id}-caption"}>{@caption}</caption>
        <colgroup :if={
          Enum.any?(@col, & &1[:col_attrs]) or Enum.any?(@action, & &1[:col_attrs])
        }>
          <col :for={col <- @col} {col[:col_attrs] || []} />
          <col :for={action <- @action} {action[:col_attrs] || []} />
        </colgroup>
        <thead>
          <tr>
            <th :for={col <- @col} scope="col">{col[:label]}</th>
            <th :for={action <- @action} scope="col">{action[:label]}</th>
          </tr>
        </thead>
        <tbody
          id={@id <> "-tbody"}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
            <td :for={col <- @col} phx-click={@row_click && @row_click.(row)}>
              {render_slot(col, @row_item.(row))}
            </td>
            <td :for={action <- @action}>
              {render_slot(action, @row_item.(row))}
            </td>
          </tr>
        </tbody>
        <tfoot :if={@foot != []}>{render_slot(@foot)}</tfoot>
      </table>
    </div>
    """
  end
end
