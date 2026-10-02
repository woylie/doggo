defmodule Doggo.FormTest do
  use ExUnit.Case, async: true

  alias Doggo.Form

  doctest Doggo.Form

  describe "input_aria_errormessage/2" do
    test "returns nil without errors" do
      assert Form.input_aria_errormessage("pet-name", []) == nil
    end

    test "returns the error id with errors" do
      assert Form.input_aria_errormessage("pet-name", ["is invalid"]) ==
               "pet-name-errors"
    end
  end

  describe "translate_error/1" do
    test "returns the message without values" do
      assert Form.translate_error({"can't be blank", [validation: :required]}) ==
               "can't be blank"
    end

    test "interpolates values" do
      assert Form.translate_error({"must have %{count} items", [count: 3]}) ==
               "must have 3 items"
    end
  end

  describe "id_fragment/1" do
    test "matches Phoenix.HTML.Form.input_id/3" do
      for value <- ["golden retriever", "a&b", "hündchen", "sit.stay", 42] do
        assert "dog_breeds_" <> Form.id_fragment(value) ==
                 Phoenix.HTML.Form.input_id(:dog, :breeds, value)
      end
    end
  end
end
