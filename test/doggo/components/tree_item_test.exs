defmodule Doggo.Components.TreeItemTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_tree_item()
  end

  describe "tree_item/1" do
    test "renders leaf without children" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree_item>
          Breeds
        </TestComponents.tree_item>
        """)

      assert attribute(html, "li:root", "role") == "treeitem"
      assert attribute(html, ":root", "aria-expanded") == nil
      assert attribute(html, ":root", "aria-selected") == "false"
      assert text(html, ":root > span") == "Breeds"
      assert Floki.find(html, ":root ul") == []
    end

    test "hides children if collapsed" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree_item expanded={false}>
          Breeds
          <:items>
            <TestComponents.tree_item>Golden Retriever</TestComponents.tree_item>
          </:items>
        </TestComponents.tree_item>
        """)

      assert attribute(html, ":root", "aria-expanded") == "false"
      assert attribute(html, "li:root > ul", "hidden") == "hidden"
    end

    test "renders selected state with selected" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree_item selected>Breeds</TestComponents.tree_item>
        """)

      assert attribute(html, ":root", "aria-selected") == "true"
    end

    test "ignores expanded on leaf" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree_item expanded={false}>Breeds</TestComponents.tree_item>
        """)

      assert attribute(html, ":root", "aria-expanded") == nil
      assert Floki.find(html, ":root ul") == []
    end

    test "renders expanded branch with children" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree_item>
          Breeds
          <:items>
            <TestComponents.tree_item>Golden Retriever</TestComponents.tree_item>
            <TestComponents.tree_item>Labrador Retriever</TestComponents.tree_item>
          </:items>
        </TestComponents.tree_item>
        """)

      assert attribute(html, "li:root", "role") == "treeitem"
      assert attribute(html, ":root", "aria-expanded") == "true"
      assert attribute(html, ":root", "aria-selected") == "false"
      assert text(html, ":root > span") == "Breeds"

      assert ul = find_one(html, "li:root > ul")
      assert attribute(ul, "role") == "group"
      assert attribute(ul, "hidden") == nil

      assert li = find_one(ul, "li:first-child")
      assert attribute(li, "role") == "treeitem"
      assert attribute(li, ":root", "aria-expanded") == nil
      assert attribute(li, ":root", "aria-selected") == "false"
      assert text(li, ":root > span") == "Golden Retriever"
      assert Floki.find(li, ":root ul") == []

      assert li = find_one(ul, "li:last-child")
      assert attribute(li, "role") == "treeitem"
      assert attribute(li, ":root", "aria-expanded") == nil
      assert attribute(li, ":root", "aria-selected") == "false"
      assert text(li, ":root > span") == "Labrador Retriever"
      assert Floki.find(li, ":root ul") == []
    end
  end
end
