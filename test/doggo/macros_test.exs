defmodule Doggo.MacrosTest do
  use ExUnit.Case, async: true

  defp compile(module, body) do
    Code.compile_string("""
    defmodule Doggo.MacrosTest.#{module} do
      use Doggo.Components
      use Phoenix.Component

      #{body}
    end
    """)
  end

  describe "build options" do
    test "reject a global attribute as a modifier name" do
      assert_raise ArgumentError,
                   ~r/build_button\/1 cannot use :hidden as a modifier name/,
                   fn ->
                     compile(
                       GlobalModifier,
                       "build_button(modifiers: [hidden: [type: :boolean]])"
                     )
                   end
    end

    test "reject a modifier that is also a declared attribute" do
      assert_raise ArgumentError,
                   ~r/already declares an attribute or slot with that name/,
                   fn ->
                     compile(
                       DeclaredModifier,
                       "build_button(modifiers: [disabled: [type: :boolean]])"
                     )
                   end
    end

    test "reject a modifier that is also a declared slot" do
      assert_raise ArgumentError,
                   ~r/already declares an attribute or slot with that name/,
                   fn ->
                     compile(
                       SlotModifier,
                       "build_alert(modifiers: [icon: [values: [\"a\"]]])"
                     )
                   end
    end

    test "reject a modifier named class" do
      assert_raise ArgumentError,
                   ~r/cannot use :class as a modifier name/,
                   fn ->
                     compile(
                       ClassModifier,
                       "build_button(modifiers: [class: []])"
                     )
                   end
    end

    test "reject a name that Phoenix.Component imports" do
      assert_raise ArgumentError,
                   ~r/build_button_link\/1 cannot generate a function called link\/1/,
                   fn -> compile(LinkName, "build_button_link(name: :link)") end
    end

    test "reject a build in a module without use Doggo.Components" do
      assert_raise ArgumentError,
                   ~r/build_badge\/1 must be called in a module that uses Doggo.Components/,
                   fn ->
                     Code.compile_string("""
                     defmodule Doggo.MacrosTest.WithoutUse do
                       import Doggo.Components
                       use Phoenix.Component

                       build_badge()
                     end
                     """)
                   end
    end
  end
end
