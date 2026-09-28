defmodule Doggo.ChangeTrackingTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Doggo.FixtureComponents

  defp field(assigns) do
    ~H"""
    <FixtureComponents.field name="dog" label={@label} value="" errors={@errors} />
    """
  end

  defp render(fun, assigns, changed) do
    assigns |> Map.put(:__changed__, changed) |> fun.() |> sent_parts()
  end

  describe "field/1" do
    test "sends the error references if the errors changed" do
      assigns = %{label: "Dog", errors: ["is invalid"]}
      parts = render(&field/1, assigns, %{errors: true})
      assert ~s( aria-describedby="dog_errors") in parts
      assert ~s( aria-errormessage="dog_errors") in parts
    end
  end
end
