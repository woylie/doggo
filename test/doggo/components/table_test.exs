defmodule Doggo.Components.TableTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.LiveStream

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_table()
  end

  describe "table/1" do
    test "default" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name">{p.name}</:col>
          <:action :let={p} label="Link">link-to-{p.id}</:action>
        </TestComponents.table>
        """)

      assert attribute(html, "div:root", "class") == "table-container"
      assert attribute(html, "div:root", "tabindex") == "0"
      assert attribute(html, ":root > table", "id") == "pets"
      assert text(html, "table > thead > tr > th:first-child") == "Name"
      assert text(html, "table > thead > tr > th:last-child") == "Link"
      assert attribute(html, "thead > tr > th:first-child", "scope") == "col"
      assert attribute(html, "thead > tr > th:last-child", "scope") == "col"
      assert attribute(html, "table > tbody", "id") == "pets-tbody"
      assert text(html, "tbody > tr > td:first-child") == "George"
      assert text(html, "tbody > tr > td:last-child") == "link-to-1"
    end

    test "with caption" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} caption="some text">
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      assert text(html, "table > caption") == "some text"
      assert attribute(html, "table > caption", "id") == "pets-caption"

      div = find_one(html, "div:root")
      assert attribute(div, "role") == "region"
      assert attribute(div, "aria-labelledby") == "pets-caption"
      assert attribute(div, "aria-label") == nil
    end

    test "with label" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} label="Pets">
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "role") == "region"
      assert attribute(div, "aria-label") == "Pets"
      assert attribute(div, "aria-labelledby") == nil
    end

    test "with label and caption" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table
          id="pets"
          rows={@pets}
          caption="some text"
          label="Pets"
        >
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "aria-label") == "Pets"
      assert attribute(div, "aria-labelledby") == nil
      assert text(html, "table > caption") == "some text"
    end

    test "without caption and label" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "tabindex") == "0"
      assert attribute(div, "role") == nil
      assert attribute(div, "aria-label") == nil
      assert attribute(div, "aria-labelledby") == nil
    end

    test "with col attrs on column" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name" col_attrs={[style: "width: 20%;"]}>
            {p.name}
          </:col>
          <:action :let={p} label="Link">link-to-{p.id}</:action>
        </TestComponents.table>
        """)

      assert attribute(html, "table > colgroup > col:first-child", "style") ==
               "width: 20%;"
    end

    test "with col attrs on action" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name">{p.name}</:col>
          <:action :let={p} label="Link" col_attrs={[style: "width: 20%;"]}>
            link-to-{p.id}
          </:action>
        </TestComponents.table>
        """)

      assert attribute(html, "table > colgroup > col:last-child", "style") ==
               "width: 20%;"
    end

    test "with foot" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={p} label="Name">{p.name}</:col>
          <:foot>some foot</:foot>
        </TestComponents.table>
        """)

      assert text(html, "table > tfoot") == "some foot"
    end

    test "with row id" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_id={&"row-#{&1.id}"}>
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody > tr", "id") == "row-1"
    end

    test "with row click" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_click={&"clicked-#{&1.id}"}>
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody td", "phx-click") == "clicked-1"
    end

    test "with row item" do
      assigns = %{pets: [%{id: 1, name: "George"}]}

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets} row_item={&Map.put(&1, :name, "G")}>
          <:col :let={p} label="Name">{p.name}</:col>
        </TestComponents.table>
        """)

      assert text(html, "tbody td") == "G"
    end

    test "with stream" do
      assigns = %{
        pets:
          LiveStream.new(
            :pets,
            0,
            [%{id: 1, name: "George"}, %{id: 2, name: "Mary"}],
            []
          )
      }

      html =
        parse_heex(~H"""
        <TestComponents.table id="pets" rows={@pets}>
          <:col :let={{id, p}} label="Name">{id} {p.name}</:col>
        </TestComponents.table>
        """)

      assert attribute(html, "tbody", "phx-update") == "stream"
      assert attribute(html, "tbody tr:first-child", "id") == "pets-1"
      assert attribute(html, "tbody tr:last-child", "id") == "pets-2"
      assert text(html, "tbody tr:first-child td") == "pets-1 George"
      assert text(html, "tbody tr:last-child td") == "pets-2 Mary"
    end
  end
end
