defmodule Doggo.Components.FallbackTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_fallback()
  end

  describe "fallback/1" do
    test "renders value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value="dog" />
        """)

      assert html == ["dog"]
    end

    test "formats value with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value="dog" formatter={&String.upcase/1} />
        """)

      assert html == ["DOG"]
    end

    test "renders placeholder for nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value={nil} />
        """)

      assert html == [
               {"span",
                [
                  {"class", "fallback"},
                  {"role", "img"},
                  {"aria-label", "Not set"}
                ], ["-"]}
             ]
    end

    test "renders placeholder for empty string with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value="" formatter={&String.upcase/1} />
        """)

      assert html == [
               {"span",
                [
                  {"class", "fallback"},
                  {"role", "img"},
                  {"aria-label", "Not set"}
                ], ["-"]}
             ]
    end

    test "renders placeholder for whitespace-only string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value="  " />
        """)

      assert [{"span", _, ["-"]}] = html
    end

    test "renders placeholder if formatter returns empty string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value={[1]} formatter={fn _ -> " " end} />
        """)

      assert [{"span", _, ["-"]}] = html
    end

    test "renders custom placeholder" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value={[]} placeholder="n/a" />
        """)

      assert html == [
               {"span",
                [
                  {"class", "fallback"},
                  {"role", "img"},
                  {"aria-label", "Not set"}
                ], ["n/a"]}
             ]
    end

    test "renders accessibility text as aria-label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.fallback value={[]} accessibility_text="not available" />
        """)

      assert html == [
               {"span",
                [
                  {"class", "fallback"},
                  {"role", "img"},
                  {"aria-label", "not available"}
                ], ["-"]}
             ]
    end
  end
end
