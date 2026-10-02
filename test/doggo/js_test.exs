defmodule Doggo.JSTest do
  use ExUnit.Case, async: true

  alias Doggo.JS

  describe "show_modal/2" do
    test "dispatches doggo:open" do
      assert %Phoenix.LiveView.JS{ops: ops} = JS.show_modal("pet-modal")

      assert [["dispatch", %{event: "doggo:open", to: "#pet-modal"}]] = ops
    end

    test "escapes the id in the selector" do
      assert %Phoenix.LiveView.JS{ops: ops} = JS.show_modal("pet:1.2")

      assert [["dispatch", %{to: "#pet\\:1\\.2"}]] = ops
    end
  end

  describe "hide_modal/2" do
    test "dispatches doggo:close" do
      assert %Phoenix.LiveView.JS{ops: ops} = JS.hide_modal("pet-modal")

      assert [["dispatch", %{event: "doggo:close", to: "#pet-modal"}]] = ops
    end
  end

  describe "show_tab/3" do
    test "dispatches doggo:show-tab with the index" do
      assert %Phoenix.LiveView.JS{ops: ops} = JS.show_tab("pet-tabs", 2)

      assert [
               [
                 "dispatch",
                 %{
                   event: "doggo:show-tab",
                   to: "#pet-tabs",
                   detail: %{index: 2}
                 }
               ]
             ] = ops
    end
  end

  describe "id_selector/1" do
    test "keeps ids that need no escaping" do
      assert JS.id_selector("pet-modal_1") == "#pet-modal_1"
    end

    test "escapes selector syntax" do
      assert JS.id_selector("pet:1.2") == "#pet\\:1\\.2"
      assert JS.id_selector("a b") == "#a\\ b"
    end

    test "escapes a leading digit" do
      assert JS.id_selector("1pet") == "#\\31 pet"
      assert JS.id_selector("-1pet") == "#-\\31 pet"
    end

    test "escapes a lone hyphen" do
      assert JS.id_selector("-") == "#\\-"
    end

    test "escapes control characters" do
      assert JS.id_selector("a\tb") == "#a\\9 b"
    end

    test "keeps non-ASCII characters" do
      assert JS.id_selector("hündchen") == "#hündchen"
    end
  end
end
