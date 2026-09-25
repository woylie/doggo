defmodule Doggo.Components.ClusterTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_cluster()
  end

  describe "cluster/1" do
    test "renders cluster" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.cluster>Hello</TestComponents.cluster>
        """)

      div = find_one(html, "div")

      assert attribute(div, "class") == "cluster"
      assert attribute(div, "role") == nil
      assert text(div) == "Hello"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.cluster data-what="ever">Hello</TestComponents.cluster>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end
end
