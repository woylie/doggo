defmodule Doggo.DiagnosticsTest do
  # async: false because the application environment is modified
  use ExUnit.Case, async: false
  use Phoenix.Component

  import Phoenix.LiveViewTest

  setup do
    on_exit(fn -> Application.put_env(:doggo, :diagnostics, true) end)
  end

  defp compile(module, diagnostics, body) do
    Application.put_env(:doggo, :diagnostics, diagnostics)

    [{module, _}] =
      Code.compile_string("""
      defmodule Doggo.DiagnosticsTest.#{module} do
        use Doggo.Components
        use Phoenix.Component

        #{body}
      end
      """)

    module
  end

  @toggletip """
  build_toggletip()

  def page(assigns) do
    ~H|<.toggletip id="fee-info" labelledby="fees">Covers vaccinations.</.toggletip>|
  end
  """

  @field """
  build_field(types: %{"week" => nil})

  def page(assigns) do
    ~H|<.field name="x" value="" label="X" type={@type} />|
  end
  """

  describe "toggletip/1" do
    test "raises for a missing icon with diagnostics" do
      module = compile(WithDiagnostics, true, @toggletip)

      assert_raise ArgumentError, ~r/missing icon for toggletip/, fn ->
        rendered_to_string(module.page(%{}))
      end
    end

    test "renders without checks without diagnostics" do
      module = compile(WithoutDiagnostics, false, @toggletip)

      assert rendered_to_string(module.page(%{})) =~ ~s(aria-labelledby="fees")
    end
  end

  describe "field/1" do
    test "raises for a type the build does not allow with diagnostics" do
      module = compile(FieldWithDiagnostics, true, @field)

      for type <- ["week", "unregistered"] do
        assert_raise ArgumentError, ~r/invalid type for .field/, fn ->
          rendered_to_string(module.page(%{type: type}))
        end
      end
    end

    test "renders an input for a type the build does not allow without diagnostics" do
      module = compile(FieldWithoutDiagnostics, false, @field)

      for type <- ["week", "unregistered"] do
        assert rendered_to_string(module.page(%{type: type})) =~
                 ~s(type="#{type}")
      end
    end
  end
end
