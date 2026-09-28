defmodule Doggo.DiagnosticsTest do
  # async: false because the application environment is modified
  use ExUnit.Case, async: false
  use Phoenix.Component

  import Phoenix.LiveViewTest

  setup do
    on_exit(fn -> Application.put_env(:doggo, :diagnostics, true) end)
  end

  defp compile(module, diagnostics) do
    Application.put_env(:doggo, :diagnostics, diagnostics)

    [{module, _}] =
      Code.compile_string("""
      defmodule Doggo.DiagnosticsTest.#{module} do
        use Doggo.Components
        use Phoenix.Component

        build_toggletip()

        def page(assigns) do
          ~H|<.toggletip id="fee-info" labelledby="fees">Covers vaccinations.</.toggletip>|
        end
      end
      """)

    module
  end

  describe "toggletip/1" do
    test "raises for a missing icon with diagnostics" do
      module = compile(WithDiagnostics, true)

      assert_raise ArgumentError, ~r/missing icon for toggletip/, fn ->
        rendered_to_string(module.page(%{}))
      end
    end

    test "renders without checks without diagnostics" do
      module = compile(WithoutDiagnostics, false)

      assert rendered_to_string(module.page(%{})) =~ ~s(aria-labelledby="fees")
    end
  end
end
