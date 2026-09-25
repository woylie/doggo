defmodule Doggo.Components.FieldTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Doggo.Components.FieldTest

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_field(gettext_module: Doggo.Gettext)

    build_field(
      name: :field_with_optional_text,
      gettext_module: Doggo.Gettext,
      optional_text: "(optional)"
    )

    build_field(name: :field_without_gettext, optional_text: "(optional)")

    build_field(
      name: :field_with_extra_types,
      gettext_module: Doggo.Gettext,
      extra_types: %{"ranked" => &FieldTest.ranked_input/1}
    )

    build_field(
      name: :field_with_group_type,
      gettext_module: Doggo.Gettext,
      extra_types: %{
        "permissions" => {&FieldTest.permissions_input/1, group: true}
      }
    )

    build_field(
      name: :field_with_replaced_select,
      gettext_module: Doggo.Gettext,
      extra_types: %{"select" => &FieldTest.ranked_input/1}
    )
  end

  @doc false
  def ranked_input(assigns) do
    ~H"""
    <div
      class="ranked"
      data-type={@type}
      data-keys={Enum.join(Enum.sort(Map.keys(assigns)), ",")}
    >
      <select
        name={@name}
        id={@id}
        aria-describedby={@describedby}
        aria-errormessage={@errormessage}
        aria-invalid={@invalid && "true"}
        {@validations}
        {@rest}
      >
        <option
          :for={n <- 1..5}
          value={n}
          selected={to_string(n) == to_string(@value)}
        >
          {n}
        </option>
      </select>
    </div>
    """
  end

  @doc false
  def permissions_input(assigns) do
    ~H"""
    <input type="hidden" name={@name <> "[]"} value="" />
    <label :for={{label, value, description} <- @options}>
      <input
        type="checkbox"
        name={@name <> "[]"}
        id={@id <> "_" <> value}
        value={value}
        checked={Doggo.checked?(value, @value)}
        aria-describedby={@describedby}
        aria-errormessage={@errormessage}
        aria-invalid={@invalid && "true"}
      />
      <span>{label}</span>
      <span class="hint">{description}</span>
    </label>
    """
  end

  describe "field/1 with options given as keyword lists" do
    test "renders extra keys as attributes" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:pet]}
            type="select"
            label="Pet"
            options={[
              [key: "Dog", value: "dog"],
              [key: "Cat", value: "cat", disabled: true]
            ]}
          />
        </.form>
        """)

      assert text(html, "option[value='dog']") == "Dog"
      assert attribute(html, "option[value='cat']", "disabled") == "disabled"
      assert attribute(html, "option[value='dog']", "disabled") == nil
    end

    test "selects option with selected key" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:pet]}
            type="select"
            label="Pet"
            options={[[key: "Cat", value: "cat", selected: true]]}
          />
        </.form>
        """)

      assert attribute(html, "option[value='cat']", "selected") == "selected"
    end
  end

  describe "field/1 with hidden_input false" do
    test "leaves out false input for checkbox" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:subscribe]}
            type="checkbox"
            label="Subscribe"
            hidden_input={false}
          />
        </.form>
        """)

      assert Floki.find(html, "input[type='hidden']") == []
      assert attribute(html, "input[type='checkbox']", "name") == "subscribe"
    end

    test "leaves out the false input for a switch" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:subscribe]}
            type="switch"
            label="Subscribe"
            hidden_input={false}
          />
        </.form>
        """)

      assert Floki.find(html, "input[type='hidden']") == []
    end

    test "renders the false input by default" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:subscribe]}
            type="checkbox"
            label="Subscribe"
          />
        </.form>
        """)

      assert attribute(html, "input[type='hidden']", "value") == "false"
    end
  end

  describe "field/1 without a form field" do
    test "renders from name and value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field name="pet" value="Bandit" label="Pet" />
        """)

      assert attribute(html, "input", "name") == "pet"
      assert attribute(html, "input", "value") == "Bandit"
      assert text(html, "label") =~ "Pet"
    end

    test "renders registered type from name and value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field_with_extra_types
          name="rank"
          value="3"
          type="ranked"
          label="Rank"
        />
        """)

      assert attribute(html, ".ranked > select", "name") == "rank"

      assert attribute(html, ".ranked > select > option[selected]", "value") ==
               "3"
    end
  end

  describe "build_field/1 with an invalid :extra_types option" do
    test "raises if the option is not a map" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromAVariable do
            use Doggo.Components
            use Phoenix.Component

            types = %{"ranked" => &FieldTest.ranked_input/1}
            build_field(name: :bad_field, extra_types: types)
          end
        end

      assert error.message =~ "Invalid :extra_types option"
      assert error.message =~ "The option has to be a map"
    end

    test "raises if a type name is not a string" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromAnAtomKey do
            use Doggo.Components
            use Phoenix.Component

            build_field(
              name: :bad_field,
              extra_types: %{ranked: &FieldTest.ranked_input/1}
            )
          end
        end

      assert error.message =~ "Invalid type name in :extra_types"
    end
  end

  describe "field/1 with extra types" do
    test "replaces built-in type with registered type of same name" do
      assigns = %{form: to_form(%{"pet" => "2"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_replaced_select
            field={@form[:pet]}
            type="select"
            label="Pet"
            options={[{"Dog", "1"}, {"Cat", "2"}]}
          />
        </.form>
        """)

      assert attribute(html, ".ranked", "data-type") == "select"
    end

    test "names group with legend" do
      assigns = %{form: to_form(%{"perms" => ["read"]})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_group_type
            field={@form[:perms]}
            type="permissions"
            label="Permissions"
            options={[
              {"Read", "read", "See everything"},
              {"Write", "write", "Change everything"}
            ]}
          />
        </.form>
        """)

      assert Floki.find(html, "label[for]") == []
      assert text(html, "fieldset > legend") =~ "Permissions"
      assert attribute(html, "fieldset", "class") == "field-permissions"

      assert text(html, "fieldset label:first-of-type .hint") ==
               "See everything"

      assert attribute(html, "input[value='read']", "checked") == "checked"

      assert find_one(html, ".field > .field-errors")
    end

    test "renders registered type with caller's component" do
      assigns = %{form: to_form(%{"rank" => "3"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_extra_types
            field={@form[:rank]}
            type="ranked"
            label="Rank"
          />
        </.form>
        """)

      assert attribute(html, ".field", "class") == "field"
      assert text(html, "label") == "Rank"

      select = find_one(html, ".ranked > select")
      assert attribute(select, "name") == "rank"
      assert attribute(select, "id") == "rank"
      assert attribute(html, ".ranked", "data-type") == "ranked"

      assert attribute(html, ".ranked > select > option[selected]", "value") ==
               "3"
    end

    test "passes the aria attributes to the caller's control" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_extra_types
            field={@form[:rank]}
            type="ranked"
            label="Rank"
            errors={["is invalid"]}
          >
            <:description>Pick a rank.</:description>
          </TestComponents.field_with_extra_types>
        </.form>
        """)

      select = find_one(html, ".ranked > select")
      assert attribute(select, "aria-invalid") == "true"
      assert attribute(select, "aria-errormessage") == "rank_errors"
      assert attribute(select, "aria-describedby") =~ "rank_description"

      assert text(html, ".field-errors > li") == "is invalid"
      assert Floki.find(html, ".ranked .field-errors") == []
    end

    test "passes an explicit set of assigns to the registered type" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_extra_types
            field={@form[:rank]}
            type="ranked"
            label="Rank"
          />
        </.form>
        """)

      assert attribute(html, ".ranked", "data-keys") ==
               "__changed__,describedby,errormessage,id,invalid,multiple," <>
                 "name,options,prompt,rest,type,validations,value"
    end

    test "keeps the built-in types" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_extra_types
            field={@form[:email]}
            type="email"
            label="Email"
          />
        </.form>
        """)

      assert attribute(html, "input", "type") == "email"
    end

    test "renders an input for an unregistered type" do
      assigns = %{form: to_form(%{}), type: "unregistered"}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_extra_types
            field={@form[:x]}
            type={@type}
            label="X"
          />
        </.form>
        """)

      assert attribute(html, "input", "type") == "unregistered"
    end
  end

  describe "field/1" do
    test "renders text input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:age]} label="Age" />
        </.form>
        """)

      input = find_one(html, "input")
      assert attribute(input, "id") == "age"
      assert attribute(input, "name") == "age"
      assert attribute(input, "type") == "text"
      assert attribute(input, "aria-describedby") == nil
      assert attribute(input, "aria-invalid") == nil
      assert attribute(input, "aria-errormessage") == nil

      assert attribute(html, "label", "for") == "age"
      assert text(html, "label") == "Age"
    end

    test "renders description" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:age]} label="Age">
            <:description>How old?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert text(html, ".field-description") == "How old?"
      assert attribute(html, ".field-description", "id") == "age_description"
      assert attribute(html, "input", "aria-describedby") == "age_description"
    end

    test "hides label visually with hide_label" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:age]} label="Age" hide_label />
        </.form>
        """)

      label = find_one(html, "label")
      assert attribute(label, "data-visually-hidden") == "data-visually-hidden"
    end

    test "renders required text" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:age]}
            label="Age"
            validations={[required: true]}
          />
        </.form>
        """)

      span = find_one(html, "label > span.field-required-mark")
      assert text(span) == "(required)"
    end

    test "renders required text without gettext module" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_without_gettext
            field={@form[:age]}
            label="Age"
            validations={[required: true]}
          />
        </.form>
        """)

      span = find_one(html, "label > span.field-required-mark")
      assert text(span) == "(required)"
    end

    test "renders optional text" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_optional_text field={@form[:age]} label="Age" />
        </.form>
        """)

      span = find_one(html, "label > span.field-optional-mark")
      assert text(span) == "(optional)"
    end

    test "renders optional text without gettext module" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_without_gettext field={@form[:age]} label="Age" />
        </.form>
        """)

      span = find_one(html, "label > span.field-optional-mark")
      assert text(span) == "(optional)"
    end

    test "renders nested options in checkbox group" do
      assigns = %{form: to_form(%{"color" => ["green"]})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:color]}
            type="checkbox-group"
            options={[
              {"Cool", [{"Blue", "blue"}, {"Green", "green"}]},
              {"Warm", [{"Red", "red"}]}
            ]}
            label="Color"
          />
        </.form>
        """)

      groups = Floki.find(html, "fieldset.field-option-group")
      assert length(groups) == 2

      assert groups |> hd() |> Floki.find("legend") |> Floki.text() ==
               "Cool"

      assert attribute(html, "input[value='green']", "checked") == "checked"
      assert attribute(html, "input[value='red']", "id") == "color_red"
    end

    test "renders nested options in radio group" do
      assigns = %{form: to_form(%{"size" => "l"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:size]}
            type="radio-group"
            options={[{"Big", [{"Large", "l"}]}, {"Small", [{"Tiny", "t"}]}]}
            label="Size"
          />
        </.form>
        """)

      groups = Floki.find(html, "fieldset.field-option-group")
      assert length(groups) == 2

      assert groups |> hd() |> Floki.find("legend") |> Floki.text() ==
               "Big"

      assert attribute(html, "input[value='l']", "checked") == "checked"
    end

    test "renders option descriptions in checkbox group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:color]}
            type="checkbox-group"
            options={[
              [key: "Blue", value: "blue", description: "The colour of the sky"],
              [key: "Green", value: "green", description: "The colour of grass"]
            ]}
            label="Color"
          />
        </.form>
        """)

      assert text(html, "#color_blue_description") == "The colour of the sky"

      assert attribute(html, "input[value='blue']", "aria-describedby") ==
               "color_blue_description"

      assert text(html, "label:first-of-type") == "Blue"
    end

    test "raises for select option with description" do
      assigns = %{form: to_form(%{})}

      error =
        assert_raise ArgumentError, fn ->
          parse_heex(~H"""
          <.form for={@form}>
            <TestComponents.field
              field={@form[:pet]}
              type="select"
              label="Pet"
              options={[[key: "Dog", value: "dog", description: "Loyal"]]}
            />
          </.form>
          """)
        end

      assert error.message =~ "Invalid :description on a select option"
    end

    test "disables option in checkbox group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:color]}
            type="checkbox-group"
            label="Color"
            options={[
              [key: "Blue", value: "blue"],
              [key: "Green", value: "green", disabled: true]
            ]}
          />
        </.form>
        """)

      assert attribute(html, "input[value='green']", "disabled") == "disabled"
      assert attribute(html, "input[value='blue']", "disabled") == nil
    end

    test "renders option descriptions in radio group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:size]}
            type="radio-group"
            options={[[key: "Large", value: "l", description: "Fits everyone"]]}
            label="Size"
          />
        </.form>
        """)

      assert text(html, "#size_l_description") == "Fits everyone"

      assert attribute(html, "input[value='l']", "aria-describedby") ==
               "size_l_description"
    end

    test "keeps field description with option description" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:color]}
            type="checkbox-group"
            options={[
              [key: "Blue", value: "blue", description: "The colour of the sky"]
            ]}
            label="Color"
          >
            <:description>Pick as many as you like.</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "input[value='blue']", "aria-describedby") ==
               "color_description color_blue_description"
    end

    test "renders optional text for checkbox group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_optional_text
            field={@form[:color]}
            type="checkbox-group"
            options={["blue", "green"]}
            label="Color"
          />
        </.form>
        """)

      span = find_one(html, "legend > span.field-optional-mark")
      assert text(span) == "(optional)"
    end

    test "renders optional text for radio group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field_with_optional_text
            field={@form[:color]}
            type="radio-group"
            options={["blue", "green"]}
            label="Color"
          />
        </.form>
        """)

      span = find_one(html, "legend > span.field-optional-mark")
      assert text(span) == "(optional)"
    end

    test "renders checkbox" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:subscribe]}
            label="Subscribe"
            type="checkbox"
          >
            <:description>Please do.</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "label", "class") == "field-checkbox"
      assert attribute(html, "input[type='hidden']", "value") == "false"

      assert text(html, ".field-description") == "Please do."

      assert attribute(html, ".field-description", "id") ==
               "subscribe_description"

      assert attribute(html, "input[type='checkbox']", "aria-describedby") ==
               "subscribe_description"

      assert attribute(html, "input[type='checkbox']", "value") == "true"
    end

    test "renders checked value for checkbox" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:subscribe]}
            label="Subscribe"
            type="checkbox"
            checked_value="yes"
          >
            <:description>Please do.</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "input[type='checkbox']", "value") == "yes"
    end

    test "renders checkbox group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:animals]}
            label="Animals"
            type="checkbox-group"
            options={[{"Dog", "dog"}, "cat", "rabbit_id", :elk]}
            value={["dog", "elk"]}
          >
            <:description>Which animals?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert text(html, "fieldset > legend") == "Animals"
      assert attribute(html, "input[type='hidden']", "name") == "animals[]"
      assert attribute(html, "input[type='hidden']", "value") == ""

      input = find_one(html, "input[id='animals_dog']")
      assert attribute(input, "value") == "dog"

      input = find_one(html, "input[id='animals_cat']")
      assert attribute(input, "value") == "cat"
    end

    test "renders radio group" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:animals]}
            label="Animals"
            type="radio-group"
            options={[{"Dog", "dog"}, "cat", "rabbit_id", :elk]}
          >
            <:description>Which animals?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert text(html, "fieldset > legend") == "Animals"

      input = find_one(html, "input[id='animals_dog']")
      assert attribute(input, "value") == "dog"

      input = find_one(html, "input[id='animals_cat']")
      assert attribute(input, "value") == "cat"
    end

    test "renders unchecked switch" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:subscribe]}
            label="Subscribe"
            type="switch"
          >
            <:description>Subscribe?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert text(html, ".field-switch-state-on") == "On"
      assert text(html, ".field-switch-state-off") == "Off"
      refute attribute(html, "input[role='switch']", "checked")
    end

    test "renders checked switch" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:subscribe]}
            label="Subscribe"
            type="switch"
            checked
          >
            <:description>Subscribe?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert text(html, ".field-switch-state-on") == "On"
      assert text(html, ".field-switch-state-off") == "Off"
      assert attribute(html, "input[role='switch']", "checked")
    end

    test "renders select" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:animals]}
            label="Animals"
            type="select"
            options={[{"Dog", "dog"}, :hr, {"Cat", "cat"}]}
            value="dog"
          >
            <:description>Which animals?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "option:first-child", "value") == "dog"
      assert attribute(html, "option:first-child", "selected") == "selected"
      assert attribute(html, "option:last-child", "value") == "cat"
      assert attribute(html, "option:last-child", "selected") == nil

      # Check if the <hr /> is the middle option
      options = html |> Floki.find("select") |> hd() |> elem(2)
      assert [_, {"hr", [], []}, _] = options
    end

    test "escapes select options" do
      assigns = %{form: to_form(%{"animals" => "dog"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:animals]}
            label="Animals"
            type="select"
            options={[{"Dog", :dog}, :hr, {"Cat", :cat}]}
          >
            <:description>Which animals?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "option:first-child", "value") == "dog"
      assert attribute(html, "option:first-child", "selected") == "selected"
      assert attribute(html, "option:last-child", "value") == "cat"
      assert attribute(html, "option:last-child", "selected") == nil

      # Check if the <hr /> is the middle option
      options = html |> Floki.find("select") |> hd() |> elem(2)
      assert [_, {"hr", [], []}, _] = options
    end

    test "renders multiple select" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:animals]}
            label="Animals"
            type="select"
            options={[[key: "Dog", value: "dog"], %{"Cat" => "cat"}]}
            multiple
            value={["dog", "cat"]}
          >
            <:description>Which animals?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "select", "multiple") == "multiple"
      assert attribute(html, "option:first-child", "selected") == "selected"
      assert attribute(html, "option:last-child", "selected") == "selected"
    end

    test "renders option groups in select" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:animals]}
            label="Animals"
            type="select"
            options={[{"Canines", %{"Dog" => "dog"}}, {"Felines", [{"Cat", "cat"}]}]}
            multiple
            value={["dog", "cat"]}
          >
            <:description>Which animals?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "select", "multiple") == "multiple"

      assert attribute(html, "optgroup:first-child", "label") == "Canines"
      assert attribute(html, "optgroup:last-child", "label") == "Felines"

      assert attribute(
               html,
               "optgroup:first-child option:first-child",
               "selected"
             ) == "selected"

      assert attribute(
               html,
               "optgroup:last-child option:last-child",
               "selected"
             ) == "selected"
    end

    test "renders textarea" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:bio]} label="Bio" type="textarea">
            <:description>Tell us more about you.</:description>
          </TestComponents.field>
        </.form>
        """)

      textarea = find_one(html, "textarea")
      assert attribute(textarea, "id") == "bio"
      assert attribute(textarea, "name") == "bio"
      assert attribute(textarea, "aria-describedby") == "bio_description"

      assert attribute(html, "label", "for") == "bio"
      assert text(html, "label") == "Bio"
    end

    test "renders file input without value" do
      assigns = %{form: to_form(%{"avatar" => "uploads/avatar.png"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:avatar]} label="Avatar" type="file" />
        </.form>
        """)

      input = find_one(html, "input")
      assert attribute(input, "type") == "file"
      assert attribute(input, "name") == "avatar"
      assert attribute(input, "value") == nil
      assert attribute(input, "multiple") == nil
    end

    test "renders multiple on file input with multiple" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:docs]}
            label="Documents"
            type="file"
            multiple
          />
        </.form>
        """)

      input = find_one(html, "input")
      assert attribute(input, "name") == "docs[]"
      assert attribute(input, "multiple") == "multiple"
    end

    test "renders hidden input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:sentiment]} type="hidden" value="jaja" />
        </.form>
        """)

      assert attribute(html, "input", "type") == "hidden"
      assert attribute(html, "input", "name") == "sentiment"
      assert attribute(html, "input", "value") == "jaja"
    end

    test "renders hidden input per list value" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:sentiment]}
            type="hidden"
            value={["ja", "ne"]}
          />
        </.form>
        """)

      assert attribute(html, "input:first-child", "type") == "hidden"
      assert attribute(html, "input:last-child", "type") == "hidden"
      assert attribute(html, "input:first-child", "name") == "sentiment[]"
      assert attribute(html, "input:last-child", "name") == "sentiment[]"
      assert attribute(html, "input:first-child", "value") == "ja"
      assert attribute(html, "input:last-child", "value") == "ne"
    end

    test "renders add-ons" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:addons]} type="text">
            <:addon_left>left</:addon_left>
            <:addon_right>right</:addon_right>
          </TestComponents.field>
        </.form>
        """)

      assert text(html, ".field-input-wrapper > .field-input-addon-left") ==
               "left"

      assert text(html, ".field-input-wrapper > .field-input-addon-right") ==
               "right"

      assert attribute(html, ".field-input-wrapper", "data-addon") ==
               "left right"
    end

    test "renders left add-on" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:addons]} type="text">
            <:addon_left>left</:addon_left>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, ".field-input-wrapper", "data-addon") == "left"
    end

    test "renders right add-on" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:addons]} type="text">
            <:addon_right>right</:addon_right>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, ".field-input-wrapper", "data-addon") == "right"
    end

    test "omits add-on data attribute without add-ons" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:addons]} type="text" />
        </.form>
        """)

      assert attribute(html, ".field-input-wrapper", "data-addon") == nil
    end

    test "renders datalist" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:species]}
            type="text"
            options={["option_a", {"Option B", "option_b"}]}
          />
        </.form>
        """)

      assert attribute(html, "input", "list") == "species_datalist"
      assert attribute(html, "datalist", "id") == "species_datalist"

      assert attribute(html, "datalist > option:first-child", "value") ==
               "option_a"

      assert attribute(html, "datalist > option:last-child", "value") ==
               "option_b"

      assert text(html, "datalist > option:first-child") == "option_a"
      assert text(html, "datalist > option:last-child") == "Option B"
    end

    test "renders errors" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:species]} type="text" errors={["wrong"]} />
        </.form>
        """)

      assert attribute(html, "input", "aria-invalid") == "true"
      assert attribute(html, "input", "aria-errormessage") == "species_errors"
      assert attribute(html, "input", "aria-describedby") == "species_errors"
      assert attribute(html, "ul", "id") == "species_errors"
      assert attribute(html, "ul", "class") == "field-errors"
      assert text(html, ".field-errors > li") == "wrong"
    end

    test "references errors and description" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:species]} type="text" errors={["wrong"]}>
            <:description>What are you?</:description>
          </TestComponents.field>
        </.form>
        """)

      assert attribute(html, "input", "aria-invalid") == "true"
      assert attribute(html, "input", "aria-errormessage") == "species_errors"

      assert attribute(html, "input", "aria-describedby") ==
               "species_errors species_description"

      assert attribute(html, "ul", "id") == "species_errors"
      assert attribute(html, "ul", "class") == "field-errors"
      assert text(html, ".field-errors > li") == "wrong"

      assert text(html, ".field-description") == "What are you?"

      assert attribute(html, ".field-description", "id") ==
               "species_description"
    end

    test "converts datetime to date string for date input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:when]}
            type="date"
            value={~U[1900-01-01T12:00:00Z]}
          />
        </.form>
        """)

      assert attribute(html, "input", "value") == "1900-01-01"
    end

    test "converts datetime string to date string for date input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:when]}
            type="date"
            value="1900-01-01T12:00:00Z"
          />
        </.form>
        """)

      assert attribute(html, "input", "value") == "1900-01-01"
    end

    test "removes other invalid date values" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:when]} type="date" value="1900-01" />
        </.form>
        """)

      assert attribute(html, "input", "value") == ""
    end

    test "converts date to date string for date input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:when]}
            type="date"
            value={~D[1900-01-01]}
          />
        </.form>
        """)

      assert attribute(html, "input", "value") == "1900-01-01"
    end

    test "converts naive datetime to date string for date input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:when]}
            type="date"
            value={~N[1900-01-01 12:00:00]}
          />
        </.form>
        """)

      assert attribute(html, "input", "value") == "1900-01-01"
    end

    test "keeps valid date string for date input" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:when]}
            type="date"
            value="1900-01-01"
          />
        </.form>
        """)

      assert attribute(html, "input", "value") == "1900-01-01"
    end

    test "removes date values that are not a valid calendar date" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={@form[:when]}
            type="date"
            value="1900-02-30"
          />
        </.form>
        """)

      assert attribute(html, "input", "value") == ""
    end

    test "removes date values that would break out of the value attribute" do
      assigns = %{form: to_form(%{}), value: ~s("><script>)}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:when]} type="date" value={@value} />
        </.form>
        """)

      assert attribute(html, "input", "value") == ""
    end

    test "removes date values that would inject an attribute" do
      assigns = %{form: to_form(%{}), value: ~s(" onload=x)}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:when]} type="date" value={@value} />
        </.form>
        """)

      assert attribute(html, "input", "value") == ""
    end

    test "renders error list as live region" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={@form[:species]} type="text" />
        </.form>
        """)

      # the region must exist before an error arrives, or the error is not
      # reliably announced
      errors = find_one(html, ".field-errors")
      assert attribute(errors, "aria-live") == "polite"
      assert attribute(errors, "id") == "species_errors"
      assert Floki.find(errors, "li") == []
    end

    test "hides errors if field is unused" do
      assigns = %{form: to_form(%{})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={%{@form[:what] | errors: [{"weird", []}]}} />
        </.form>
        """)

      assert Floki.find(html, ".field-errors > li") == []

      assigns = %{form: to_form(%{"what" => "what", "_unused_what" => ""})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={%{@form[:what] | errors: [{"weird", []}]}} />
        </.form>
        """)

      assert Floki.find(html, ".field-errors > li") == []
    end

    test "inserts gettext variables in errors without gettext module" do
      assigns = %{form: to_form(%{"what" => "what"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={
            %{@form[:what] | errors: [{"weird %{animal}", [animal: "dog"]}]}
          } />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "weird dog"
    end

    test "translates errors with gettext" do
      assigns = %{form: to_form(%{"what" => "what"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={%{@form[:what] | errors: [{"weird dog", []}]}} />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "chien bizarre"
    end

    test "translates errors with numbers with gettext" do
      assigns = %{form: to_form(%{"what" => "what"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field
            field={
              %{
                @form[:what]
                | errors: [
                    {"only %{count} dog(s) allowed", [count: 5]}
                  ]
              }
            }
            gettext={Doggo.Gettext}
          />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "seulement 5 chiens autorisés"
    end
  end
end
