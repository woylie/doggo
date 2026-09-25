defmodule Doggo.Components.RadioGroupTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_radio_group()
  end

  describe "radio_group/1" do
    test "renders radio group with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog_name"
          label="Favorite Dog"
          value="german_shepherd"
          options={[
            {"Labrador Retriever", "labrador"},
            {"German Shepherd", "german_shepherd"}
          ]}
        />
        """)

      assert attribute(html, "div:root", "role") == "radiogroup"
      assert attribute(html, ":root", "id") == "favorite_dog_rg"
      assert attribute(html, ":root", "aria-label") == "Favorite Dog"

      input = find_one(html, "label:first-child input")
      assert attribute(input, "type") == "radio"
      assert attribute(input, "id") == "favorite_dog_rg_labrador"
      assert attribute(input, "name") == "favorite_dog_name"
      assert attribute(input, "checked") == nil
      assert text(html, "label:first-child") == "Labrador Retriever"

      input = find_one(html, "label:last-child input")
      assert attribute(input, "type") == "radio"
      assert attribute(input, "id") == "favorite_dog_rg_german_shepherd"
      assert attribute(input, "name") == "favorite_dog_name"
      assert attribute(input, "checked") == "checked"
      assert text(html, "label:last-child") == "German Shepherd"
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          labelledby="rg-label"
          options={[{"Labrador Retriever", "labrador"}]}
        />
        """)

      assert attribute(html, ":root", "aria-labelledby") == "rg-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          label="Favorite Dog"
          labelledby="rg-label"
          options={[{"Labrador Retriever", "labrador"}]}
        />
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          options={[{"Labrador Retriever", "labrador"}]}
        />
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.radio_group
          id="favorite_dog_rg"
          name="favorite_dog"
          labelledby="rg-label"
          options={[{"Labrador Retriever", "labrador"}]}
          data-test="hi"
        />
        """)

      assert attribute(html, ":root", "data-test") == "hi"
    end
  end
end
