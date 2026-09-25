defmodule Doggo.Components.CardTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_card()
  end

  describe "card/1" do
    test "renders card" do
      assigns = %{}
      html = parse_heex(~H"<TestComponents.card></TestComponents.card>")
      article = find_one(html, "article")
      assert attribute(article, "class") == "card"
      assert Floki.children(article) == []
    end

    test "renders image in figure" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:image>Doggo</:image>
        </TestComponents.card>
        """)

      assert text(html, "article > figure") == "Doggo"
    end

    test "renders header" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:header>Doggo</:header>
        </TestComponents.card>
        """)

      assert text(html, "article > header") == "Doggo"
    end

    test "renders body" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:body>Doggo</:body>
        </TestComponents.card>
        """)

      assert text(html, "article > div.card-body") == "Doggo"
    end

    test "renders footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card>
          <:footer>Doggo</:footer>
        </TestComponents.card>
        """)

      assert text(html, "article > footer") == "Doggo"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.card data-what="ever"></TestComponents.card>
        """)

      assert attribute(html, "article", "data-what") == "ever"
    end
  end
end
