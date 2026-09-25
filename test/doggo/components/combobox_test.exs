defmodule Doggo.Components.ComboboxTest do
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

    build_combobox()
  end

  describe "combobox/1" do
    test "renders combobox" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue", "Green"]}
          value="Green"
        />
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "combobox"
      assert attribute(div, "id") == "color-selector-combobox"
      assert attribute(div, "phx-hook") == "Doggo.Combobox"
      assert attribute(div, "data-filter") == nil

      wrapper = find_one(div, "div.combobox-input-wrapper")

      input = find_one(wrapper, "input")
      assert attribute(input, "id") == "color-selector"
      assert attribute(input, "type") == "text"
      assert attribute(input, "role") == "combobox"
      assert attribute(input, "name") == "color_search"
      assert attribute(input, "value") == "Green"
      assert attribute(input, "aria-autocomplete") == "list"
      assert attribute(input, "aria-expanded") == "false"
      assert attribute(input, "aria-controls") == "color-selector-listbox"
      assert attribute(input, "autocomplete") == "off"

      button = find_one(div, "button")
      assert attribute(button, "id") == "color-selector-button"
      assert attribute(button, "type") == "button"
      assert attribute(button, "class") == "combobox-toggle"
      assert attribute(button, "tabindex") == "-1"
      assert attribute(button, "aria-label") == "Colors"
      assert attribute(button, "aria-expanded") == "false"
      assert attribute(button, "aria-controls") == "color-selector-listbox"

      listbox = find_one(div, "div[role='listbox']")
      assert attribute(listbox, "id") == "color-selector-listbox"
      assert attribute(listbox, "aria-label") == "Colors"
      assert attribute(listbox, "hidden") == "hidden"

      assert option = find_one(listbox, "div[role='option']:first-child")
      assert attribute(option, "id") == "color-selector-option-1"
      assert attribute(option, "aria-selected") == "false"
      assert attribute(option, "data-value") == "Blue"
      span = find_one(option, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Blue"

      assert option = find_one(listbox, "div[role='option']:last-child")
      assert attribute(option, "id") == "color-selector-option-2"
      assert attribute(option, "aria-selected") == "true"
      assert attribute(option, "data-value") == "Green"
      span = find_one(option, "span:last-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Green"

      input = find_one(div, "input[type='hidden']")
      assert attribute(input, "id") == "color-selector-value"
      assert attribute(input, "name") == "color"
      assert attribute(input, "value") == "Green"
    end

    test "derives search input name from bracket name" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="dog[color]"
          list_label="Colors"
          options={["Blue", "Green"]}
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "name") == "dog[color_search]"

      input = find_one(html, "input[type='hidden']")
      assert attribute(input, "name") == "dog[color]"
    end

    test "renders option labels" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}, {"Green", "green"}]}
          value="green"
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "value") == "Green"

      input = find_one(html, "input[type='hidden']")
      assert attribute(input, "value") == "green"

      listbox = find_one(html, "div[role='listbox']")

      option = find_one(listbox, "div[role='option']:first-child")
      assert attribute(option, "data-value") == "blue"
      span = find_one(option, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Blue"

      option = find_one(listbox, "div[role='option']:last-child")
      assert attribute(option, "data-value") == "green"
      span = find_one(option, "span:last-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Green"
    end

    test "matches option with non-string value" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"One", 1}, {"Two", 2}]}
          value="1"
        />
        """)

      assert attribute(html, "input[type='text']", "value") == "One"

      option = find_one(html, "div#color-selector-option-1")
      assert attribute(option, "aria-selected") == "true"
      assert attribute(option, "data-value") == "1"
    end

    test "renders name for list of values" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="dog[color][]"
          list_label="Colors"
          options={["Blue"]}
        />
        """)

      assert attribute(html, "input[type='hidden']", "name") == "dog[color][]"

      assert attribute(html, "input[type='text']", "name") ==
               "dog[color_search]"
    end

    test "renders option descriptions" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[
            [key: "Hakodate", value: "hakodate", description: "Hokkaido"],
            [key: "Kanazawa", value: "kanazawa", description: "Ishikawa"]
          ]}
          value="hakodate"
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "value") == "Hakodate"

      input = find_one(html, "input[type='hidden']")
      assert attribute(input, "value") == "hakodate"

      listbox = find_one(html, "div[role='listbox']")

      option = find_one(listbox, "div[role='option']:first-child")
      assert attribute(option, "data-value") == "hakodate"
      span = find_one(option, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Hakodate"
      span = find_one(option, "span:last-child")
      assert attribute(span, "class") == "combobox-option-description"
      assert text(span) == "Hokkaido"

      option = find_one(listbox, "div[role='option']:last-child")
      assert attribute(option, "data-value") == "kanazawa"
      span = find_one(option, "span:first-child")
      assert attribute(span, "class") == "combobox-option-label"
      assert text(span) == "Kanazawa"
      span = find_one(option, "span:last-child")
      assert attribute(span, "class") == "combobox-option-description"
      assert text(span) == "Ishikawa"
    end

    test "accepts options as map" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[%{"Blue" => "blue"}]}
          value="blue"
        />
        """)

      option = find_one(html, "div[role='option']")
      assert attribute(option, "data-value") == "blue"
      assert text(find_one(option, "span")) == "Blue"
      assert attribute(html, "input[type='text']", "value") == "Blue"
    end

    test "renders option groups" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[
            {"Cool", [{"Blue", "blue"}]},
            {"Warm", [{"Red", "red"}, {"Orange", "orange"}]}
          ]}
          value="red"
        />
        """)

      listbox = find_one(html, "div[role='listbox']")

      group = find_one(listbox, "div[role='group']:first-child")
      assert attribute(group, "class") == "combobox-option-group"
      assert attribute(group, "aria-labelledby") == "color-selector-group-1"

      label = find_one(group, "span#color-selector-group-1")
      assert attribute(label, "class") == "combobox-option-group-label"
      assert text(label) == "Cool"

      option = find_one(group, "div[role='option']")
      assert attribute(option, "id") == "color-selector-option-1"
      assert attribute(option, "data-value") == "blue"

      group = find_one(listbox, "div[role='group']:last-child")
      assert attribute(group, "aria-labelledby") == "color-selector-group-2"
      assert text(find_one(group, "span#color-selector-group-2")) == "Warm"

      assert ["color-selector-option-2", "color-selector-option-3"] ==
               group
               |> Floki.find("div[role='option']")
               |> Enum.map(&attribute(&1, "id"))

      assert attribute(html, "div#color-selector-option-2", "aria-selected") ==
               "true"

      assert attribute(html, "input[type='text']", "value") == "Red"
    end

    test "renders free text option with free_text" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          free_text
          free_text_label="Add colour"
        />
        """)

      option = find_one(html, "div#color-selector-option-free-text")
      assert attribute(option, "role") == "option"
      assert attribute(option, "class") == "combobox-option-free-text"
      assert attribute(option, "aria-selected") == "false"
      assert attribute(option, "data-free-text") == "data-free-text"
      assert attribute(option, "hidden") == "hidden"
      assert text(option, "span.combobox-option-label") == "Add colour"
      assert text(option, "span.combobox-option-term") == ""
    end

    test "omits free text option without free_text" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
        />
        """)

      assert [] = Floki.find(html, "[data-free-text]")
    end

    test "raises for free_text without label" do
      assigns = %{}

      assert_raise ArgumentError, ~r/missing free_text_label/, fn ->
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          free_text
        />
        """)
      end
    end

    test "drops group without options" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Empty", []}, {"Warm", [{"Red", "red"}]}]}
        />
        """)

      assert [group] = Floki.find(html, "div[role='group']")
      assert text(find_one(group, "span.combobox-option-group-label")) == "Warm"

      assert attribute(group, "aria-labelledby") == "color-selector-group-1"
    end

    test "marks only first option with value" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}, {"Also blue", "blue"}]}
          value="blue"
        />
        """)

      assert ["color-selector-option-1"] ==
               html
               |> Floki.find("div[aria-selected='true']")
               |> Enum.map(&attribute(&1, "id"))
    end

    test "renders blank option" do
      for options <- [[nil, {"Blue", "blue"}], [{"", ""}, {"Blue", "blue"}]] do
        assigns = %{options: options}

        html =
          parse_heex_without_name_check(~H"""
          <TestComponents.combobox
            id="color-selector"
            name="color"
            list_label="Colors"
            options={@options}
          />
          """)

        assert attribute(html, "div#color-selector-option-1", "data-value") ==
                 ""
      end
    end

    test "renders aria-labelledby on input" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          aria-labelledby="color-heading"
          options={[{"Blue", "blue"}]}
        />
        """)

      assert attribute(html, "input[role='combobox']", "aria-labelledby") ==
               "color-heading"
    end

    test "omits clear button by default" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}]}
          value="blue"
        />
        """)

      assert Floki.find(html, "button[data-clear]") == []
    end

    test "renders clear button with clearable" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          clearable
          clear_label="Clear the colour"
          options={[{"Blue", "blue"}]}
          value="blue"
        />
        """)

      button = find_one(html, "button#color-selector-clear")

      assert attribute(button, "type") == "button"
      assert attribute(button, "tabindex") == "-1"
      assert attribute(button, "aria-label") == "Clear the colour"
      assert attribute(button, "hidden") == nil
    end

    test "hides clear button without value" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          clearable
          options={[{"Blue", "blue"}]}
        />
        """)

      assert attribute(html, "button#color-selector-clear", "hidden") ==
               "hidden"
    end

    test "renders clear and toggle slots" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          clearable
          options={[{"Blue", "blue"}]}
          value="blue"
        >
          <:clear>clear-icon</:clear>
          <:toggle>toggle-icon</:toggle>
        </TestComponents.combobox>
        """)

      clear = find_one(html, "button#color-selector-clear")
      toggle = find_one(html, "button#color-selector-button")

      assert text(clear) == "clear-icon"
      assert text(toggle) == "toggle-icon"
      assert attribute(clear, "aria-label") == "Clear"
      assert attribute(toggle, "aria-label") == "Colors"
    end

    test "renders separator" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}, :hr, {"Red", "red"}]}
        />
        """)

      assert [hr] = Floki.find(html, "div[role='listbox'] > hr")

      assert attribute(hr, "aria-hidden") == "true"
    end

    test "marks disabled option" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[
            [key: "Blue", value: "blue"],
            [key: "Red", value: "red", disabled: true]
          ]}
        />
        """)

      assert attribute(html, "div#color-selector-option-1", "aria-disabled") ==
               nil

      assert attribute(html, "div#color-selector-option-2", "aria-disabled") ==
               "true"
    end

    test "raises for tuple that is not label and value" do
      assigns = %{}

      assert_raise ArgumentError, ~r/unsupported option for \.combobox/, fn ->
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue", "Cool"}]}
        />
        """)
      end
    end

    test "raises for unsupported option key" do
      assigns = %{}

      assert_raise ArgumentError, ~r/unsupported option keys/, fn ->
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[[key: "Blue", value: "blue", selected: true]]}
        />
        """)
      end
    end

    test "renders value if no option matches" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}]}
          value="turquoise"
        />
        """)

      assert attribute(html, "input[type='text']", "value") == "turquoise"
      assert attribute(html, "input[type='hidden']", "value") == "turquoise"
    end

    test "renders display_value" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}]}
          value="turquoise"
          display_value="Turquoise"
        />
        """)

      assert attribute(html, "input[type='text']", "value") == "Turquoise"
      assert attribute(html, "input[type='hidden']", "value") == "turquoise"
    end

    test "renders display_value over matching option label" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={[{"Blue", "blue"}]}
          value="blue"
          display_value="Something else"
        />
        """)

      assert attribute(html, "input[type='text']", "value") == "Something else"
    end

    test "filters on server with on_search" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          on_search={JS.push("suggest")}
        />
        """)

      assert attribute(html, ":root", "data-filter") == "server"

      input = find_one(html, "input[type='text']")
      assert attribute(input, "phx-change") =~ "suggest"
      assert attribute(input, "phx-debounce") == "300"
    end

    test "overrides debounce with phx-debounce" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          on_search={JS.push("suggest")}
          phx-debounce="blur"
        />
        """)

      assert attribute(html, "input[type='text']", "phx-debounce") == "blur"
    end

    test "omits debounce without on_search" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "phx-change") == nil
      assert attribute(input, "phx-debounce") == nil
    end

    test "filters on server with event name as on_search" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          on_search="suggest"
        />
        """)

      assert attribute(html, ":root", "data-filter") == "server"
      assert attribute(html, "input[type='text']", "phx-change") == "suggest"
    end

    test "renders global attributes on input" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          data-what="ever"
        />
        """)

      assert attribute(html, "input[type='text']", "data-what") == "ever"
      assert attribute(html, ":root", "data-what") == nil
    end

    test "turns autocomplete off by default" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
        />
        """)

      assert attribute(html, "input[type='text']", "autocomplete") == "off"
    end

    test "overrides autocomplete" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          autocomplete="on"
        />
        """)

      input = find_one(html, "input[type='text']")
      assert attribute(input, "autocomplete") == "on"
    end

    test "renders disabled and form on both inputs" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          disabled
          form="colors"
        />
        """)

      for selector <- ["input[type='text']", "input[type='hidden']"] do
        input = find_one(html, selector)
        assert attribute(input, "disabled") == "disabled"
        assert attribute(input, "form") == "colors"
      end
    end

    test "keeps other global attributes off hidden input" do
      assigns = %{}

      html =
        parse_heex_without_name_check(~H"""
        <TestComponents.combobox
          id="color-selector"
          name="color"
          list_label="Colors"
          options={["Blue"]}
          placeholder="Search"
        />
        """)

      assert attribute(html, "input[type='text']", "placeholder") == "Search"
      assert attribute(html, "input[type='hidden']", "placeholder") == nil
    end
  end
end
