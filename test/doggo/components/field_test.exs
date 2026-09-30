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

    build_field(translate_error: &FieldTest.translate_error/1)

    build_field(
      name: :field_with_optional_text,
      translate_error: &FieldTest.translate_error/1,
      optional_text: "(optional)"
    )

    build_field(
      name: :field_with_extra_types,
      translate_error: &FieldTest.translate_error/1,
      types: %{"ranked" => &FieldTest.ranked_input/1}
    )

    build_field(
      name: :field_with_group_type,
      translate_error: &FieldTest.translate_error/1,
      types: %{
        "permissions" => {&FieldTest.permissions_input/1, group: true}
      }
    )

    build_field(
      name: :field_with_replaced_select,
      translate_error: &FieldTest.translate_error/1,
      types: %{"select" => &FieldTest.ranked_input/1}
    )

    build_field(
      name: :field_with_removed_types,
      types: %{"week" => nil, "color" => nil, "text" => :default}
    )
  end

  @doc false
  @translations %{
    "weird dog" => "chien bizarre",
    "only %{count} dog(s) allowed" => "seulement %{count} chiens autorisés"
  }

  def translate_error({msg, opts}) do
    Doggo.translate_error({Map.get(@translations, msg, msg), opts})
  end

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

  describe "build_field/1 with :types from a module attribute" do
    test "registers types" do
      defmodule FromAnAttribute do
        use Doggo.Components
        use Phoenix.Component

        @types %{"ranked" => &FieldTest.ranked_input/1}
        build_field(name: :attribute_field, types: @types)
      end

      assigns = %{}

      html =
        parse_heex(~H"""
        <FromAnAttribute.attribute_field
          name="rank"
          value="3"
          label="Rank"
          type="ranked"
        />
        """)

      assert attribute(html, ".ranked", "data-type") == "ranked"
    end
  end

  describe "build_field/1 with :types" do
    test "removes types set to nil from type values" do
      %{attrs: attrs} =
        TestComponents.__components__()[:field_with_removed_types]

      values = Enum.find(attrs, &(&1.name == :type)).opts[:values]

      refute "week" in values
      refute "color" in values
      assert "text" in values
      assert "select" in values
    end

    test "raises if the option is not a map" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromAList do
            use Doggo.Components
            use Phoenix.Component

            build_field(name: :bad_field, types: ["ranked"])
          end
        end

      assert error.message =~ "invalid :types option for build_field/1"
    end

    test "raises if a type name is not a string" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromAnAtomKey do
            use Doggo.Components
            use Phoenix.Component

            build_field(
              name: :bad_field,
              types: %{ranked: &FieldTest.ranked_input/1}
            )
          end
        end

      assert error.message =~ "invalid type name in :types"
    end

    test "raises for nil on a type that is not built in" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromUnknownNil do
            use Doggo.Components
            use Phoenix.Component

            build_field(name: :bad_field, types: %{"ranked" => nil})
          end
        end

      assert error.message =~ "apply to built-in types only"
    end

    test "raises for an invalid entry" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromInvalidEntry do
            use Doggo.Components
            use Phoenix.Component

            build_field(name: :bad_field, types: %{"ranked" => :ranked})
          end
        end

      assert error.message =~ "invalid entry in :types"
    end
  end

  describe "build_field/1 with :gettext_module" do
    test "raises with the replacement" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromGettextModule do
            use Doggo.Components
            use Phoenix.Component

            build_field(gettext_module: MyAppWeb.Gettext)
          end
        end

      assert error.message =~
               "the :gettext_module option of build_field/1 was replaced"

      assert error.message =~
               "translate_error: &MyAppWeb.CoreComponents.translate_error/1"
    end
  end

  describe "build_field/1 with an expression as required_text" do
    test "evaluates the text at render time" do
      defmodule WithRenderText do
        use Doggo.Components
        use Phoenix.Component

        build_field(required_text: Process.get(:required_text, "required"))
      end

      assigns = %{}
      Process.put(:required_text, "Pflichtfeld")

      html =
        parse_heex(~H"""
        <WithRenderText.field
          name="age"
          label="Age"
          value=""
          validations={[required: true]}
        />
        """)

      assert text(html, "label > span.field-required-mark") == "Pflichtfeld"
    end
  end

  describe "build_field/1 with :extra_types" do
    test "raises an error" do
      error =
        assert_raise ArgumentError, fn ->
          defmodule FromExtraTypes do
            use Doggo.Components
            use Phoenix.Component

            build_field(
              name: :extra_field,
              extra_types: %{"ranked" => &FieldTest.ranked_input/1}
            )
          end
        end

      assert error.message =~ "was replaced by :types"
    end
  end

  describe "field/1 with types" do
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
      assert attribute(select, "aria-errormessage") == "rank-errors"
      assert attribute(select, "aria-describedby") =~ "rank-description"

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
      assert attribute(html, ".field-description", "id") == "age-description"
      assert attribute(html, "input", "aria-describedby") == "age-description"
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

      assert text(html, "#color_blue-description") == "The colour of the sky"

      assert attribute(html, "input[value='blue']", "aria-describedby") ==
               "color_blue-description"

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

      assert error.message =~ "invalid :description on an option for .field"
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

      assert text(html, "#size_l-description") == "Fits everyone"

      assert attribute(html, "input[value='l']", "aria-describedby") ==
               "size_l-description"
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
               "color-description color_blue-description"
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

      assert attribute(html, "label", "class") == "field-label field-checkbox"
      assert attribute(html, "input[type='hidden']", "value") == "false"

      assert text(html, ".field-description") == "Please do."

      assert attribute(html, ".field-description", "id") ==
               "subscribe-description"

      assert attribute(html, "input[type='checkbox']", "aria-describedby") ==
               "subscribe-description"

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
      assert attribute(textarea, "aria-describedby") == "bio-description"

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

      assert attribute(html, "input", "list") == "species-datalist"
      assert attribute(html, "datalist", "id") == "species-datalist"

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
      assert attribute(html, "input", "aria-errormessage") == "species-errors"
      assert attribute(html, "input", "aria-describedby") == "species-errors"
      assert attribute(html, "ul", "id") == "species-errors"
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
      assert attribute(html, "input", "aria-errormessage") == "species-errors"

      assert attribute(html, "input", "aria-describedby") ==
               "species-errors species-description"

      assert attribute(html, "ul", "id") == "species-errors"
      assert attribute(html, "ul", "class") == "field-errors"
      assert text(html, ".field-errors > li") == "wrong"

      assert text(html, ".field-description") == "What are you?"

      assert attribute(html, ".field-description", "id") ==
               "species-description"
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
      assert attribute(errors, "id") == "species-errors"
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

    test "interpolates values in errors without translate_error" do
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

    test "translates errors with translate_error" do
      assigns = %{form: to_form(%{"what" => "what"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={%{@form[:what] | errors: [{"weird dog", []}]}} />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "chien bizarre"
    end

    test "translates errors with values with translate_error" do
      assigns = %{form: to_form(%{"what" => "what"})}

      html =
        parse_heex(~H"""
        <.form for={@form}>
          <TestComponents.field field={
            %{
              @form[:what]
              | errors: [
                  {"only %{count} dog(s) allowed", [count: 5]}
                ]
            }
          } />
        </.form>
        """)

      assert text(html, ".field-errors > li") == "seulement 5 chiens autorisés"
    end

    test "keeps option ids apart from field ids for option value errors" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field
          type="checkbox-group"
          name="tags"
          label="Tags"
          value={[]}
          errors={["pick one"]}
          options={["errors", "description"]}
        >
          <:description>Pick the tags.</:description>
        </TestComponents.field>
        """)

      ids = Floki.attribute(html, "[id]", "id")
      assert ids == Enum.uniq(ids)
      assert "tags-errors" in ids
      assert "tags_errors" in ids
    end

    test "derives checkbox option ids without whitespace" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field
          type="checkbox-group"
          name="breeds"
          label="Breeds"
          value={[]}
          options={[
            [
              key: "Golden Retriever",
              value: "golden retriever",
              description: "Friendly"
            ]
          ]}
        />
        """)

      input = find_one(html, "input[type='checkbox']")
      assert attribute(input, "id") == "breeds_golden_retriever"

      assert attribute(input, "aria-describedby") =~
               "breeds_golden_retriever-description"
    end

    test "renders only classes and data attributes listed in the safelist" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <div>
          <TestComponents.field
            :for={type <- ~w(text textarea file hidden checkbox switch)}
            type={type}
            name={type}
            label={type}
            value=""
            errors={["is invalid"]}
            hide_label
          >
            <:description>Description</:description>
          </TestComponents.field>
          <TestComponents.field type="text" name="addon" label="Addon" value="">
            <:addon_left>left</:addon_left>
            <:addon_right>right</:addon_right>
          </TestComponents.field>
          <TestComponents.field
            type="text"
            name="list"
            label="List"
            value=""
            options={["a", "b"]}
          />
          <TestComponents.field
            type="select"
            name="select"
            label="Select"
            value={[]}
            multiple
            options={[{"Group", ["a", "b"]}]}
          />
          <TestComponents.field
            :for={type <- ~w(checkbox-group radio-group)}
            type={type}
            name={type}
            label={type}
            value={[]}
            validations={[required: true]}
            options={[[key: "A", value: "a", description: "Option"], {"Group", ["b"]}]}
          />
        </div>
        """)

      safelist = Doggo.safelist(TestComponents)

      classes =
        html
        |> Floki.attribute("[class]", "class")
        |> Enum.flat_map(&String.split/1)

      data_attrs =
        for {_, attrs, _} <- Floki.find(html, "*"),
            {name, _} <- attrs,
            String.starts_with?(name, "data-"),
            do: name

      assert Enum.uniq(classes) -- safelist == []
      assert Enum.uniq(data_attrs) -- safelist == []
    end
  end
end
