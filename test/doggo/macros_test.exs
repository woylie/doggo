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

  describe "build_button/1" do
    test "raises for global attribute as modifier name" do
      assert_raise ArgumentError,
                   ~r/invalid modifier name for build_button\/1.*Got:\s+:hidden/s,
                   fn ->
                     compile(
                       GlobalModifier,
                       "build_button(modifiers: [hidden: [type: :boolean]])"
                     )
                   end
    end

    test "raises for modifier named like declared attribute" do
      assert_raise ArgumentError,
                   ~r/already declares an attribute or slot with that name/,
                   fn ->
                     compile(
                       DeclaredModifier,
                       "build_button(modifiers: [disabled: [type: :boolean]])"
                     )
                   end
    end

    test "raises for modifier named like included attribute" do
      assert_raise ArgumentError,
                   ~r/invalid modifier name for build_button\/1.*Got:\s+:value/s,
                   fn ->
                     compile(
                       IncludedModifier,
                       "build_button(modifiers: [value: [values: [\"a\"]]])"
                     )
                   end
    end

    test "raises for modifier named class" do
      assert_raise ArgumentError,
                   ~r/invalid modifier name for build_button\/1.*Got:\s+:class/s,
                   fn ->
                     compile(
                       ClassModifier,
                       "build_button(modifiers: [class: []])"
                     )
                   end
    end
  end

  describe "build_alert/1" do
    test "raises for modifier named like slot" do
      assert_raise ArgumentError,
                   ~r/already declares an attribute or slot with that name/,
                   fn ->
                     compile(
                       SlotModifier,
                       "build_alert(modifiers: [icon: [values: [\"a\"]]])"
                     )
                   end
    end
  end

  describe "build_button_link/1" do
    test "raises for modifier named like attribute in include list" do
      assert_raise ArgumentError,
                   ~r/invalid modifier name for build_button_link\/1.*Got:\s+:target/s,
                   fn ->
                     compile(
                       IncludedListModifier,
                       "build_button_link(modifiers: [target: [values: [\"_blank\"]]])"
                     )
                   end
    end

    test "raises for name imported by Phoenix.Component" do
      assert_raise ArgumentError,
                   ~r/build_button_link\/1 cannot generate a function called link\/1/,
                   fn -> compile(LinkName, "build_button_link(name: :link)") end
    end
  end

  describe "build_badge/1" do
    test "raises if module does not use Doggo.Components" do
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
