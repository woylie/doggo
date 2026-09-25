defmodule Doggo.Components.ButtonTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_button()
  end

  describe "button/1" do
    test "renders button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button>Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "disabled") == nil

      assert attribute(button, "class") == "button"
      assert attribute(button, "data-variant") == "primary"
      assert attribute(button, "data-size") == "normal"
      assert attribute(button, "data-fill") == "solid"

      assert text(button) == "Confirm"
    end

    test "adds class from string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button class="mt-4">Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")

      assert attribute(button, "class") == "button mt-4"
    end

    test "adds multiple classes from string" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button class="mt-4 mb-2">Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")

      assert attribute(button, "class") == "button mt-4 mb-2"
    end

    test "adds multiple classes from list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button class={["mt-4", "mb-2"]}>Confirm</TestComponents.button>
        """)

      button = find_one(html, "button:root")

      assert attribute(button, "class") == "button mt-4 mb-2"
    end

    test "renders disabled button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button disabled>Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "renders type" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button type="submit">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "type") == "submit"
    end

    test "renders variant as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button variant="danger">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-variant") == "danger"
    end

    test "renders size as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button size="large">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-size") == "large"
    end

    test "renders shape as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button shape="pill">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-shape") == "pill"
    end

    test "renders fill as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button fill="outline">Confirm</TestComponents.button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-fill") == "outline"
    end
  end
end
