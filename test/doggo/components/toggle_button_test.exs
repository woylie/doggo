defmodule Doggo.Components.ToggleButtonTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_toggle_button()
  end

  describe "toggle_button/1" do
    test "renders unpressed toggle button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")}>
          Mute
        </TestComponents.toggle_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-pressed") == "false"
      assert attribute(button, "phx-click")
      assert text(button) == "Mute"
    end

    test "renders pressed state with pressed" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")} pressed>
          Mute
        </TestComponents.toggle_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-pressed") == "true"
      assert attribute(button, "phx-click")
      assert text(button) == "Mute"
    end

    test "renders disabled button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")} disabled>
          Mute
        </TestComponents.toggle_button>
        """)

      assert attribute(html, "button:root", "disabled") == "disabled"
    end

    test "renders variant as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click={JS.push("toggle-mute")} variant="danger">
          Mute
        </TestComponents.toggle_button>
        """)

      assert attribute(html, "button:root", "class") == "button"
      assert attribute(html, "button:root", "data-variant") == "danger"
    end

    test "pushes event name with on_click event name" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button on_click="toggle-mute">
          Mute
        </TestComponents.toggle_button>
        """)

      ops =
        html
        |> attribute("button:root", "phx-click")
        |> Phoenix.json_library().decode!()

      assert ["push", %{"event" => "toggle-mute"}] in ops
    end

    test "raises for invalid on_click" do
      assigns = %{on_click: :mute}

      assert_raise ArgumentError,
                   ~r/invalid on_click value for \.toggle_button/,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.toggle_button on_click={@on_click}>
                       Mute
                     </TestComponents.toggle_button>
                     """)
                   end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggle_button
          on_click={JS.push("toggle-mute")}
          data-test="hello"
        >
          Mute
        </TestComponents.toggle_button>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
