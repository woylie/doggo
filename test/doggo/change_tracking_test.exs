defmodule Doggo.ChangeTrackingTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Doggo.FixtureComponents

  defp button(assigns) do
    ~H"""
    <FixtureComponents.button variant={@variant} class={@class} data-probe="x">
      {@label}
    </FixtureComponents.button>
    """
  end

  defp frame(assigns) do
    ~H"""
    <FixtureComponents.frame ratio={@ratio} data-probe="x">
      {@content}
    </FixtureComponents.frame>
    """
  end

  defp image(assigns) do
    ~H"""
    <FixtureComponents.image src={@src} alt="A dog" ratio={@ratio} data-probe="x">
      <:caption>{@caption}</:caption>
    </FixtureComponents.image>
    """
  end

  defp icon(assigns) do
    ~H"""
    <FixtureComponents.icon name={@name} label={@label} data-probe="x" />
    """
  end

  defp date(assigns) do
    ~H"""
    <FixtureComponents.date value={@value} data-probe="x" />
    """
  end

  defp field(assigns) do
    ~H"""
    <FixtureComponents.field name="dog" label={@label} value="" errors={@errors} />
    """
  end

  defp form_field(assigns) do
    ~H"""
    <FixtureComponents.field field={@form[:dog]} label={@label} />
    """
  end

  defp checkbox(assigns) do
    ~H"""
    <FixtureComponents.field field={@form[:good]} label={@label} type="checkbox" />
    """
  end

  defp toggle_button(assigns) do
    ~H"""
    <FixtureComponents.toggle_button
      pressed={@pressed}
      on_click="toggle"
      data-probe="x"
    >
      {@label}
    </FixtureComponents.toggle_button>
    """
  end

  defp render(fun, assigns, changed) do
    assigns |> Map.put(:__changed__, changed) |> fun.() |> sent_parts()
  end

  describe "button/1" do
    @assigns %{variant: "primary", class: nil, label: "Save"}

    test "sends only the content if the content changed" do
      assert render(&button/1, @assigns, %{label: true}) ==
               [~s( data-probe="x"), "Save"]
    end

    test "sends the data attributes if a modifier changed" do
      parts = render(&button/1, @assigns, %{variant: true})
      assert Enum.any?(parts, &(&1 =~ ~s(data-variant="primary")))
      refute "button" in parts
    end

    test "sends the class if the class changed" do
      parts = render(&button/1, %{@assigns | class: "wide"}, %{class: true})
      assert "button wide" in parts
      refute Enum.any?(parts, &(&1 =~ "data-variant"))
    end
  end

  describe "frame/1" do
    @assigns %{ratio: "16:9", content: "Content"}

    test "sends only the content if the content changed" do
      assert render(&frame/1, @assigns, %{content: true}) ==
               [~s( data-probe="x"), "Content"]
    end

    test "sends the ratio if the ratio changed" do
      parts = render(&frame/1, %{@assigns | ratio: "4:3"}, %{ratio: true})
      assert ~s( data-numerator="4") in parts
      assert ~s( data-denominator="3") in parts
    end
  end

  describe "image/1" do
    @assigns %{src: "dog.png", ratio: "16:9", caption: "A caption"}

    test "sends only the caption if the caption changed" do
      assert render(&image/1, @assigns, %{caption: true}) ==
               [~s( data-probe="x"), "A caption"]
    end

    test "sends the frame's ratio if the ratio changed" do
      parts = render(&image/1, %{@assigns | ratio: "4:3"}, %{ratio: true})
      assert ~s( data-numerator="4") in parts
      refute "image" in parts
    end
  end

  describe "icon/1" do
    @assigns %{name: "info", label: "Info"}

    test "sends only the label if the label changed" do
      assert render(&icon/1, @assigns, %{label: true}) ==
               [~s( data-probe="x"), "Info"]
    end
  end

  describe "date/1" do
    test "sends the value if the value changed" do
      parts = render(&date/1, %{value: ~D[2026-09-28]}, %{value: true})
      assert ~s( datetime="2026-09-28") in parts
      assert "2026-09-28" in parts
    end
  end

  describe "field/1" do
    test "sends the error references if the errors changed" do
      assigns = %{label: "Dog", errors: ["is invalid"]}
      parts = render(&field/1, assigns, %{errors: true})
      assert ~s( aria-describedby="dog-errors") in parts
      assert ~s( aria-errormessage="dog-errors") in parts
    end

    test "does not send the error references if only the label changed" do
      assigns = %{label: "Name", errors: ["is invalid"]}
      parts = render(&field/1, assigns, %{label: true})
      assert "Name" in parts
      refute ~s( aria-describedby="dog-errors") in parts
    end

    test "sends the value if the form changed" do
      form = to_form(%{"dog" => "Rex"})
      parts = render(&form_field/1, %{form: form, label: "Dog"}, %{form: true})
      assert ~s( value="Rex") in parts
    end

    test "does not send the value if only the label changed" do
      form = to_form(%{"dog" => "Rex"})
      parts = render(&form_field/1, %{form: form, label: "Dog"}, %{label: true})
      assert "Dog" in parts
      refute ~s( value="Rex") in parts
    end
  end

  describe "field/1 with type checkbox" do
    test "does not send checked if only the label changed" do
      form = to_form(%{"good" => "true"})
      parts = render(&checkbox/1, %{form: form, label: "Good"}, %{label: true})
      assert "Good" in parts
      refute " checked" in parts
    end

    test "sends checked if the form changed" do
      form = to_form(%{"good" => "true"})
      parts = render(&checkbox/1, %{form: form, label: "Good"}, %{form: true})
      assert " checked" in parts
    end
  end

  describe "toggle_button/1" do
    test "sends only the content if the content changed" do
      assigns = %{pressed: true, label: "Mute"}

      assert render(&toggle_button/1, assigns, %{label: true}) ==
               [~s( data-probe="x"), "Mute"]
    end

    test "sends aria-pressed if pressed changed" do
      assigns = %{pressed: true, label: "Mute"}
      parts = render(&toggle_button/1, assigns, %{pressed: true})
      assert ~s( aria-pressed="true") in parts
    end
  end
end
