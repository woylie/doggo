defmodule Doggo.Components.PropertyListTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_property_list()
  end

  describe "property_list/1" do
    test "renders property list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.property_list>
          <:prop label="Name">George</:prop>
        </TestComponents.property_list>
        """)

      assert attribute(html, "dl", "class") == "property-list"
      assert text(html, "dl > div > dt") == "Name"
      assert text(html, "dl > div > dd") == "George"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.property_list data-test="value">
          <:prop label="Name">George</:prop>
        </TestComponents.property_list>
        """)

      assert attribute(html, "dl", "data-test") == "value"
    end

    test "renders nothing without properties" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.property_list>
          <:prop :for={_ <- []} label="Name">George</:prop>
          <:prop :for={_ <- []} label="Breed">Dachshund</:prop>
        </TestComponents.property_list>
        """)

      assert html == []
    end

    test "raises for blank label" do
      assert_raise ArgumentError, ~r/blank label/, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.property_list>
          <:prop label="">George</:prop>
        </TestComponents.property_list>
        """)
      end
    end

    test "renders label with markup" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.property_list>
          <:prop label={~H"<b>Name</b>"}>George</:prop>
        </TestComponents.property_list>
        """)

      assert text(html, "dl > div > dt > b") == "Name"
    end
  end
end
