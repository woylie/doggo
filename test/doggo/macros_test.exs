defmodule Doggo.MacrosTest do
  use ExUnit.Case, async: true

  alias Doggo.Components.Table

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
    test "renders build options as text" do
      [{module, _}] =
        compile(QuotedBaseClass, ~S"""
        build_button(base_class: ~s|a"}{raise "x"}|)

        def page(assigns), do: ~H"<.button>Save</.button>"
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(class="a&quot;}{raise &quot;x&quot;}")
    end

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

    test "renders an expression default" do
      [{module, _}] =
        compile(ExpressionDefault, ~S"""
        def type, do: "sub"

        build_button(defaults: [type: type() <> "mit"])

        def page(assigns), do: ~H|<.button>Hi</.button>|
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(type="submit")
    end

    test "renders the value of the call instead of the default" do
      [{module, _}] =
        compile(DefaultOverride, ~S"""
        build_button(defaults: [type: String.downcase("SUBMIT")])

        def page(assigns), do: ~H|<.button type="reset">Hi</.button>|
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(type="reset")
      refute html =~ "submit"
    end

    test "keeps nil passed by the call" do
      [{module, _}] =
        compile(DefaultNil, ~S"""
        build_button(defaults: [type: String.downcase("SUBMIT")])

        def page(assigns),
          do: ~H|<.button type={@type}>Hi</.button>|
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{type: nil}))
      refute html =~ "submit"
    end

    test "does not send an expression default if another attribute changed" do
      [{module, _}] =
        compile(DefaultChangeTracking, ~S"""
        build_button(defaults: [type: String.downcase("SUBMIT")])

        def page(assigns),
          do: ~H|<.button variant={@variant}>Hi</.button>|
        """)

      parts =
        %{variant: "danger", __changed__: %{variant: true}}
        |> module.page()
        |> Doggo.TestHelpers.sent_parts()

      refute Enum.any?(parts, &(&1 =~ "submit"))
    end

    test "raises for a default that reads assigns" do
      assert_raise ArgumentError, ~r/reads the component's assigns/, fn ->
        compile(
          AssignsDefault,
          ~S|build_button(defaults: [type: assigns.variant])|
        )
      end
    end
  end

  describe "build macros" do
    test "write usage examples with the configured name" do
      for {macro, 1} <- Doggo.Components.__info__(:macros),
          "build_" <> component <- [Atom.to_string(macro)] do
        module = Module.concat(Doggo.Components, Macro.camelize(component))
        usage = module.usage(%{name: :renamed, base_class: "renamed"})

        assert usage =~ "<.renamed", component
        refute usage =~ ~r/<\.#{component}(?!\w)/, component
      end
    end

    test "write usage examples with the configured base class" do
      usage = Table.usage(%{name: :data_grid, base_class: "grid"})

      assert usage =~ ".grid-container {"
      refute usage =~ ".table-container"
    end

    test "depend on the component module at compile time" do
      env = %{__ENV__ | requires: [Doggo.Components | __ENV__.requires]}
      ast = Macro.expand_once(quote(do: Doggo.Components.build_button()), env)

      assert Macro.to_string(ast) =~
               "Doggo.Components.Button.module_info(:module)"
    end
  end

  describe "build_alert/1" do
    test "renders a slot default" do
      [{module, _}] =
        compile(SlotDefault, ~S"""
        def warning_icon(assigns), do: ~H|<b>!</b>|

        build_alert(defaults: [icon: &__MODULE__.warning_icon/1])

        def page(assigns), do: ~H|<.alert id="a">Hi</.alert>|
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ "<b>!</b>"
    end

    test "renders an inline slot default with the modifier values" do
      [{module, _}] =
        compile(InlineSlotDefault, ~S"""
        build_alert(defaults: [icon: ~H|<i data-icon={@level}></i>|])

        def page(assigns),
          do: ~H|<.alert id="a" level="warning">Hi</.alert>|
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(<i data-icon="warning"></i>)
    end

    test "sends a slot default again if a modifier changed" do
      [{module, _}] =
        compile(SlotDefaultChangeTracking, ~S"""
        build_alert(defaults: [icon: ~H|<i data-icon={@level}></i>|])

        def page(assigns),
          do: ~H|<.alert id="a" level={@level}>Hi</.alert>|
        """)

      parts =
        %{level: "danger", __changed__: %{level: true}}
        |> module.page()
        |> Doggo.TestHelpers.sent_parts()

      assert Enum.any?(parts, &(&1 =~ ~s(data-icon="danger")))
    end

    test "raises for an anonymous function as a default" do
      assert_raise ArgumentError, ~r/is an anonymous function/, fn ->
        compile(AnonymousDefault, ~S"""
        @defaults [title: fn -> "x" end]
        build_alert(defaults: @defaults)
        """)
      end
    end

    test "raises for a default of an unknown attribute" do
      assert_raise ArgumentError,
                   ~r/invalid default for build_alert\/1.*:titl.*:title/s,
                   fn ->
                     compile(
                       UnknownDefault,
                       ~S|build_alert(defaults: [titl: "x"])|
                     )
                   end
    end

    test "raises for a default of a required attribute" do
      assert_raise ArgumentError,
                   ~r/invalid default for build_alert\/1.*:id/s,
                   fn ->
                     compile(
                       RequiredDefault,
                       ~S|build_alert(defaults: [id: "a"])|
                     )
                   end
    end

    test "raises for a default of a modifier" do
      assert_raise ArgumentError, ~r/:level is a modifier.*modifiers:/s, fn ->
        compile(ModifierDefault, ~S|build_alert(defaults: [level: "info"])|)
      end
    end

    test "raises for a default of the global attributes" do
      assert_raise ArgumentError,
                   ~r/invalid default for build_alert\/1.*:rest/s,
                   fn ->
                     compile(
                       RestDefault,
                       ~S|build_alert(defaults: [rest: %{}])|
                     )
                   end
    end

    test "raises for a slot default that is not a function component" do
      assert_raise ArgumentError, ~r/The content of a slot default/, fn ->
        compile(TextSlotDefault, ~S|build_alert(defaults: [icon: "x"])|)
      end
    end

    test "raises for a default capture of a function that does not exist" do
      assert_raise ArgumentError,
                   ~r/refers to a function that does not exist/,
                   fn ->
                     compile(
                       MissingCapture,
                       ~S|build_alert(defaults: [icon: &Enum.nope/1])|
                     )
                   end
    end

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
    test "builds without a base class" do
      [{module, _}] =
        compile(ImageWithoutBaseClass, ~S"""
        build_frame()
        build_image(base_class: nil)

        def page(assigns), do: ~H"<.image src='a.png' alt='A' />"
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(class="frame -frame")
    end

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

  describe "build_field/1" do
    test "resolves module names in its template despite local aliases" do
      [{module, _}] =
        compile(AliasedDoggo, ~S"""
        alias Doggo.MacrosTest.AliasedDoggo, as: Doggo

        build_field()

        def page(assigns), do: ~H|<.field name="a" label="A" value="" errors={["bad"]} />|
        def aliased, do: Doggo
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(<div class="field-input-wrapper">)
      assert html =~ ~s(<ul id="a-errors" class="field-errors")
    end

    test "builds two fields in one module" do
      [{module, _}] =
        compile(TwoFields, ~S"""
        build_field()
        build_field(name: :search_field, base_class: "search", required_text: "*")

        def page(assigns) do
          ~H"<.field name='a' label='A' value='' validations={[required: true]} /><.search_field name='b' label='B' value='' validations={[required: true]} />"
        end
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(<div class="field">)
      assert html =~ ~s(<div class="search">)
      assert html =~ "(required)"
      assert html =~ ~s(class="search-required-mark")
    end
  end

  describe "build macros with render options" do
    test "raise for a content option that is not a function component" do
      assert_raise ArgumentError,
                   ~r/invalid :close option for build_alert\/1/,
                   fn ->
                     compile(StringContentOption, ~S|build_alert(close: "x")|)
                   end
    end

    test "raise for a content expression that is not inline HEEx" do
      assert_raise ArgumentError,
                   ~r/invalid :close option for build_alert\/1/,
                   fn ->
                     compile(
                       CallContentOption,
                       ~S|build_alert(close: String.upcase("x"))|
                     )
                   end
    end

    test "raise for an expression that reads assigns" do
      assert_raise ArgumentError,
                   ~r/The :close_label option reads the component's assigns/,
                   fn ->
                     compile(
                       AssignsRenderOption,
                       ~S|build_alert(close_label: assigns.id)|
                     )
                   end
    end

    test "raise for a function option that is not a function" do
      assert_raise ArgumentError,
                   ~r/invalid :pagination_slide_label option for build_carousel\/1/,
                   fn ->
                     compile(
                       StringFunctionOption,
                       ~S|build_carousel(pagination_slide_label: "x")|
                     )
                   end
    end
  end

  describe "build_breadcrumb/1" do
    test "applies an expression default for the label before the label check" do
      [{module, _}] =
        compile(LabelExpressionDefault, ~S"""
        build_breadcrumb(defaults: [label: String.capitalize("breadcrumb")])

        def page(assigns),
          do: ~H|<.breadcrumb><:item href="/">Home</:item></.breadcrumb>|
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~s(aria-label="Breadcrumb")
    end
  end

  describe "build_carousel/1" do
    test "renders a slot default with slot attributes" do
      [{module, _}] =
        compile(SlotAttributesDefault, ~S"""
        build_carousel(
          defaults: [
            previous: [label: String.upcase("back"), inner_block: ~H|<b>‹</b>|],
            next: [label: "Forward", inner_block: ~H|<b>›</b>|]
          ]
        )

        def page(assigns),
          do: ~H|<.carousel id="c" label="Dogs"><:item label="1">A</:item><:item label="2">B</:item></.carousel>|
        """)

      html = Phoenix.LiveViewTest.rendered_to_string(module.page(%{}))
      assert html =~ ~r/aria-label="BACK"[^>]*>\s*<b>‹<\/b>/
      assert html =~ ~r/aria-label="Forward"[^>]*>\s*<b>›<\/b>/
    end

    test "raises for a slot default without a required slot attribute" do
      assert_raise ArgumentError, ~r/Missing:\n\n\s+\[:label\]/, fn ->
        compile(
          MissingSlotAttribute,
          ~S|build_carousel(defaults: [previous: ~H"<b>‹</b>"])|
        )
      end
    end

    test "raises for a slot default with an unknown slot attribute" do
      assert_raise ArgumentError, ~r/Unknown:\n\n\s+\[:title\]/, fn ->
        compile(
          UnknownSlotAttribute,
          ~S|build_carousel(defaults: [previous: [label: "Back", title: "x", inner_block: ~H"<b>‹</b>"]])|
        )
      end
    end
  end

  describe "build_icon/1" do
    test "writes a literal default into the declaration" do
      [{module, _}] =
        compile(LiteralDefault, ~S"""
        build_icon(icon_module: Doggo.FixtureIcons, defaults: [label_position: "after"])
        """)

      %{attrs: attrs} = module.__components__()[:icon]

      assert Enum.find(attrs, &(&1.name == :label_position)).opts[:default] ==
               "after"
    end

    test "raises for a literal default that is not one of the values" do
      assert_raise ArgumentError,
                   ~r/must be one of the attribute's values/,
                   fn ->
                     compile(
                       InvalidLiteralDefault,
                       ~S|build_icon(icon_module: Doggo.FixtureIcons, defaults: [label_position: "above"])|
                     )
                   end
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
