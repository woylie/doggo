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
    test "accepts module attribute in options" do
      [{module, _}] =
        compile(AttributeOption, """
        @sizes ["small", "large"]
        build_button(modifiers: [size: [values: @sizes, default: "small"]])
        """)

      %{attrs: attrs} = module.__components__()[:button]
      size = Enum.find(attrs, &(&1.name == :size))
      assert size.opts[:values] == ["small", "large"]
    end

    test "accepts function call in options" do
      [{module, _}] =
        compile(FunctionCallOption, """
        build_button(modifiers: [size: [values: Enum.map(~w(s l), &String.upcase/1)]])
        """)

      %{attrs: attrs} = module.__components__()[:button]
      size = Enum.find(attrs, &(&1.name == :size))
      assert size.opts[:values] == ["S", "L"]
    end

    test "accepts module attribute as options" do
      [{module, _}] =
        compile(AttributeOptions, """
        @opts [name: :big_button, base_class: "big"]
        build_button(@opts)
        """)

      assert %{big_button: info} = module.__dog_components__()
      assert info[:base_class] == "big"
    end

    test "raises for anonymous function in options" do
      assert_raise ArgumentError,
                   ~r/invalid modifiers option for build_button\/1.*remote\ncapture/s,
                   fn ->
                     compile(
                       AnonymousFunction,
                       "build_button(modifiers: [size: [values: [fn -> 1 end]]])"
                     )
                   end
    end

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

  describe "build_frame/1" do
    test "raises for invalid ratio in ratios" do
      assert_raise ArgumentError,
                   ~r/invalid ratios option for build_frame\/1.*Got:\s+\["16:9", "wide"\]/s,
                   fn ->
                     compile(
                       InvalidRatio,
                       ~s|build_frame(ratios: ["16:9", "wide"])|
                     )
                   end
    end

    test "raises for empty ratios" do
      assert_raise ArgumentError,
                   ~r/invalid ratios option for build_frame\/1/,
                   fn -> compile(EmptyRatios, "build_frame(ratios: [])") end
    end

    test "raises for ratio as modifier" do
      assert_raise ArgumentError,
                   ~r/already declares an attribute or slot with that name/,
                   fn ->
                     compile(
                       RatioModifier,
                       ~s|build_frame(modifiers: [ratio: [values: ["1:1"]]])|
                     )
                   end
    end
  end

  describe "build_image/1" do
    test "raises without a frame build" do
      assert_raise ArgumentError,
                   ~r/missing frame build for image\/1.*build_frame\(\)/s,
                   fn -> compile(ImageWithoutFrame, "build_image()") end
    end

    test "raises if the frame option names a function that is not a frame build" do
      assert_raise ArgumentError, ~r/missing frame build for image\/1/, fn ->
        compile(ImageWithButtonAsFrame, """
        build_button()
        build_image(frame: &__MODULE__.button/1)
        """)
      end
    end

    test "raises for a frame option that is not a remote capture" do
      assert_raise ArgumentError,
                   ~r/invalid frame option for build_image\/1/,
                   fn ->
                     compile(
                       ImageWithAtomFrame,
                       "build_frame()\nbuild_image(frame: :frame)"
                     )
                   end
    end

    test "raises if the frame is built after the image" do
      assert_raise ArgumentError, ~r/missing frame build for image\/1/, fn ->
        compile(ImageBeforeFrame, "build_image()\nbuild_frame()")
      end
    end

    test "takes ratio values from the frame build" do
      [{module, _}] =
        compile(ImageRatios, """
        build_frame(ratios: ["1:1", "21:9"])
        build_image()
        """)

      %{attrs: attrs} = module.__components__()[:image]
      ratio = Enum.find(attrs, &(&1.name == :ratio))
      assert ratio.opts[:values] == [nil, "1:1", "21:9"]
    end

    test "accepts a frame build in another module" do
      assert [{_, _}, {module, _}] =
               Code.compile_string("""
               defmodule Doggo.MacrosTest.FrameModule do
                 use Doggo.Components
                 use Phoenix.Component

                 build_frame(ratios: ["3:2"])
               end

               defmodule Doggo.MacrosTest.ImageModule do
                 use Doggo.Components
                 use Phoenix.Component

                 build_image(frame: &Doggo.MacrosTest.FrameModule.frame/1)
               end
               """)

      %{attrs: attrs} = module.__components__()[:image]
      ratio = Enum.find(attrs, &(&1.name == :ratio))
      assert ratio.opts[:values] == [nil, "3:2"]
    end

    test "accepts a frame build under another name" do
      assert [{_module, _}] =
               compile(ImageWithNamedFrame, """
               build_frame(name: :media_frame)
               build_image(frame: &__MODULE__.media_frame/1)
               """)
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
