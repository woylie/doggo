defmodule Doggo.Components.Field do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  alias Phoenix.HTML.Form

  require Doggo

  @built_in_types ~w(checkbox checkbox-group color date datetime-local email file
                     hidden month number password range radio radio-group search
                     select switch tel text textarea time url week)

  @impl true
  def doc do
    """
    Renders a form field including input, label, errors, and description.

    A `Phoenix.HTML.FormField` may be passed as argument,
    which is used to retrieve the input name, ID, and values.
    Otherwise all attributes may be passed explicitly.
    """
  end

  @impl true
  def builder_doc do
    """
    - `:gettext_module` - If set, errors as well as the `required_text` and
      `optional_text` are automatically translated using this module. This only
      works if the `:field` attribute is set. Without it,
      errors passed to the component are rendered unchanged.
    - `:required_text` - Defines a text that is rendered next to the label
      in required fields. Defaults to `"(required)"`. This value is translated
      if `gettext_module` is set. If you use a symbol like an asterisk, it is
      good practice to add a sentence explaining that fields marked with an
      that symbol are required.
    - `:optional_text` - Defines a text that is rendered next to the label
      in optional fields. Defaults to `nil`. This value is translated
      if `gettext_module` is set.
    - `:types` - A map from a type name to the control that renders it. A map
      value can be a function component, a function component marked as a group
      (`{component, group: true}`), `:default` for the built-in control, or
      `nil` to remove a built-in type. See *Custom types* below.
    """
  end

  @impl true
  def usage do
    """
    ### Custom types

    You can register additional input types at build time with the `types`
    option.

    ```elixir
    build_field(
      types: %{"ranked" => &MyAppWeb.Inputs.ranked/1}
    )
    ```

    The additional types can be rendered like any other types.

    ```heex
    <.field field={@form[:rank]} type="ranked" label="Rank" />
    ```

    The map is merged into the built-in types. You can set an entry to `nil` to
    remove a built-in type you do not use, and to `:default` to keep the
    built-in control, for example after a shared configuration replaced it.

    ```elixir
    build_field(
      types: %{
        "select" => &MyAppWeb.Inputs.select/1,
        "color" => nil,
        "week" => nil
      }
    )
    ```

    ### Types that render a group

    Sometimes a control needs to render multiple inputs, for example a date
    field with separate selects for each segment. Set `group: true` on such
    types, so that the controls are wrapped inside a fieldset with a legend.

    ```elixir
    build_field(
      types: %{
        "permissions" => {&MyAppWeb.Inputs.permissions/1, group: true}
      }
    )
    ```

    The `fieldset` has the class `\#{base_class}-\#{type}`. Errors and
    description are rendered outside of the fieldset.

    The `options` assign can be used to pass additional options to your custom
    type. The only requirement is that it is a list.

    The field component renders the label, the errors and the description as it
    does for any other type, and calls your function component for the control.
    Your component receives these assigns:

    | Assign | |
    |---|---|
    | `name` | the input name, with `[]` appended when `multiple` is set |
    | `id` | the `id` attribute, from `id` or the form field |
    | `value` | the field value |
    | `type` | the type you registered |
    | `options` | the options the caller passed, or `nil` |
    | `prompt` | the prompt the caller passed, or `nil` |
    | `multiple` | whether the field takes more than one value |
    | `invalid` | whether the field has errors, for `aria-invalid` |
    | `describedby` | for `aria-describedby`, `nil` without a description |
    | `errormessage` | for `aria-errormessage`, `nil` without errors |
    | `validations` | the validation attributes derived from the changeset |
    | `rest` | the global attributes the caller passed |

    The component you referenced renders the control:

    ```elixir
    attr :name, :string, required: true
    attr :id, :string, required: true
    attr :value, :any, required: true
    attr :type, :string, required: true
    attr :options, :list, required: true
    attr :prompt, :string, required: true
    attr :multiple, :boolean, required: true
    attr :invalid, :boolean, required: true
    attr :describedby, :string, required: true
    attr :errormessage, :string, required: true
    attr :validations, :list, required: true
    attr :rest, :global, doc: "Any additional HTML attributes."

    def ranked(assigns) do
      ~H\"\"\"
      <div class="ranked" data-type={@type}>
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
      \"\"\"
    end
    ```

    ### Types

    In addition to all HTML input types, the following type values are also
    supported:

    - `"select"`
    - `"checkbox-group"`
    - `"radio-group"`
    - `"switch"`

    ### Class and Global Attribute

    Note that the `class` attribute is applied to the outer container, while
    the `rest` global attribute is applied to the `<input>` element.

    ### Gettext

    To translate field errors as well as the `required_text` and `optional_text`
    using Gettext, set the `gettext_module` option when building the component:

        build_field(gettext_module: MyApp.Gettext)

    ### Label positioning

    The component does not provide an attribute to modify label positioning
    directly. Instead, label positioning should be handled with CSS. If your
    application requires different label positions, such as horizontal and
    vertical layouts, it is recommended to add a modifier class to the form.

    For example, the default style could position labels above inputs. To place
    labels to the left of the inputs in a horizontal form layout, you can add an
    `is-horizontal` class to the form:

    ```heex
    <.form class="is-horizontal">
      <!-- inputs -->
    </.form>
    ```

    Then, in your CSS, apply the necessary styles to the `.field` class within
    forms having the `is-horizontal` class:

    ```css
    form.is-horizontal .field {
      // styles to position label left of the input
    }
    ```

    The component has a `hide_label` attribute to visually hide labels while still
    making them accessible to screen readers. If all labels within a form need to
    be visually hidden, it may be more convenient to define a
    `.has-visually-hidden-labels` modifier class for the `<form>`.

    ```heex
    <.form class="has-visually-hidden-labels">
      <!-- inputs -->
    </.form>
    ```

    Ensure to take checkbox and radio labels into consideration when writing the
    CSS styles.

    ### Examples

    ```heex
    <.field field={@form[:name]} />
    ```

    ```heex
    <.field field={@form[:email]} type="email" />
    ```

    #### Radio group and checkbox group

    The `radio-group` and `checkbox-group` render groups of radio buttons or
    checkboxes with a single component invocation. The `options` attribute is
    required for these types and has the same format as the options for the
    `select` type, except that options may not be nested.

    ```heex
    <.field
      field={@form[:email]}
      type="checkbox-group"
      label="Cuisine"
      options={[
        {"Mexican", "mexican"},
        {"Japanese", "japanese"},
        {"Libanese", "libanese"}
      ]}
    />
    ```

    Note that the `checkbox-group` type renders an additional hidden input with
    an empty value before the checkboxes. This ensures that a value exists in case
    all checkboxes are unchecked. Consequently, the resulting list value includes
    an extra empty string. While `Ecto.Changeset.cast/3` filters out empty strings
    in array fields by default, you may need to handle the additional empty string
    manual in other contexts.
    """
  end

  @impl true
  def keyboard do
    """
    - `Space` - toggle a checkbox or a switch.
    - `Left`, `Right`, `Up` and `Down` - move between the radios of a group and
      check the one the focus lands on.

    The controls are native elements, so the browser handles these.
    """
  end

  @impl true
  def css_path do
    "components/field.css"
  end

  @impl true
  def config do
    [
      type: :form,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [],
      data_attrs: ["data-invalid", "data-state"],
      extra: [
        gettext_module: nil,
        required_text: "(required)",
        optional_text: nil,
        types: nil,
        extra_types: nil
      ]
    ]
  end

  @impl true
  def own_attributes, do: ["aria-describedby": nil]

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-checkbox",
      "#{base_class}-checkbox-group",
      "#{base_class}-description",
      "#{base_class}-errors",
      "#{base_class}-input-addon-left",
      "#{base_class}-input-addon-right",
      "#{base_class}-input-wrapper",
      "#{base_class}-option-description",
      "#{base_class}-optional-mark",
      "#{base_class}-radio-group",
      "#{base_class}-required-mark",
      "#{base_class}-select",
      "#{base_class}-switch",
      "#{base_class}-switch-label",
      "#{base_class}-switch-state",
      "#{base_class}-switch-state-off",
      "#{base_class}-switch-state-on"
    ]
  end

  @impl true
  def attrs_and_slots(opts) do
    built_in_types = @built_in_types

    types = types!(opts)
    removed = for {name, nil} <- types, do: name
    added = for {name, entry} <- types, entry != nil, do: name

    quote do
      attr :id, :any, default: nil
      attr :name, :any

      attr :label, :string,
        default: nil,
        doc: """
        Required for all types except `"hidden"`.
        """

      attr :hide_label, :boolean,
        default: false,
        doc: """
        Adds a `data-visually-hidden` attribute to the `<label>`. This option
        does not apply to checkbox and radio inputs.

        This requires a CSS rule for the `data-visually-hidden` attribute. See
        [Visually hidden text](readme.html#visually-hidden-text).
        """

      attr :value, :any

      attr :type, :string,
        default: "text",
        values: unquote(Enum.uniq((built_in_types -- removed) ++ added))

      attr :field, Phoenix.HTML.FormField,
        doc: "A form field struct, for example: @form[:name]"

      attr :errors, :list

      attr :validations, :list,
        doc: """
        A list of HTML input validation attributes (`required`, `minlength`,
        `maxlength`, `min`, `max`, `pattern`). The attributes are derived
        automatically from the form.
        """

      attr :checked_value, :string,
        default: "true",
        doc: "The value that is sent when the checkbox is checked."

      attr :checked, :boolean, doc: "The checked attribute for checkboxes."

      attr :hidden_input, :boolean,
        default: true,
        doc: """
        If `true`, a hidden input with a `false` value is rendered before each
        checkbox, so that the form payload always has a parameter for that
        field.
        """

      attr :on_text, :string,
        default: "On",
        doc: """
        The state text for a switch when on. This value should be translated to
        the language in which the rest of the page is displayed.
        """

      attr :off_text, :string,
        default: "Off",
        doc: """
        The state text for a switch when off. This value should be translated to
        the language in which the rest of the page is displayed.
        """

      attr :prompt, :string,
        default: nil,
        doc: "An optional prompt for select elements."

      attr :options, :list,
        default: nil,
        doc: """
        A list of options.

        This attribute is supported for the following types:

        - `"select"`
        - `"radio-group"`
        - `"checkbox-group"`
        - other text types, date and time types, and the `"range"` type

        If this attribute is set for types other than select, radio, and checkbox,
        a [datalist](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/datalist)
        is rendered for the input.

        See `Phoenix.HTML.Form.options_for_select/2` for the format.

        Nested options group the choices. A select renders an `optgroup`, and a
        checkbox or radio group a nested `fieldset` with the group's name as its
        `legend`.

            options={[{"Cool", [{"Blue", "blue"}]}, {"Warm", [{"Red", "red"}]}]}

        Options can also be written as a keyword list with these keys:

        - `:key` (required)
        - `:value` (required)
        - `:description` (optional)

        Any additional keys are passed as attributes to the control.

        The description is rendered after the control and its label. It is
        only supported for checkbox and radio groups.

            options={[[key: "Blue", value: "blue", description: "Sky"]]}
        """

      attr :multiple, :boolean,
        default: false,
        doc: """
        Sets the `multiple` attribute on a select element to allow selecting
        multiple options, or on a file input to allow selecting multiple files.
        """

      attr :rest, :global,
        include:
          ~w(accept autocomplete capture cols disabled form list max maxlength min
         minlength multiple passwordrules pattern placeholder readonly required
         rows size step),
        doc: "Any additional HTML attributes."

      attr :gettext, :atom,
        doc: """
        The Gettext module to use for translating error messages. This option can
        also be set globally, see above.
        """

      slot :description,
        doc: "A field description to render underneath the input."

      slot :addon_left,
        doc: """
        Can be used to render an icon left in the input. Only supported for
        single-line inputs.
        """

      slot :addon_right,
        doc: """
        Can be used to render an icon left in the input. Only supported for
        single-line inputs.
        """
    end
  end

  @doc false
  def types!(opts) do
    if Keyword.get(opts, :extra_types) do
      raise ArgumentError, """
      the :extra_types option of build_field/1 was replaced by :types

      Please rename the option from `:extra_types` to `:types`.

      Example:

          build_field(types: %{"ranked" => &MyAppWeb.Inputs.ranked/1})
      """
    end

    validate_types!(Keyword.get(opts, :types), :types)
  end

  defp validate_types!(nil, _option), do: %{}

  defp validate_types!(%{} = types, option) do
    for {name, entry} <- types do
      validate_type_name!(name, option)
      validate_type_entry!(name, entry, option)
    end

    types
  end

  defp validate_types!(other, option) do
    raise ArgumentError, """
    invalid #{inspect(option)} option for build_field/1

    The option has to be a map from type names to entries.

    Got:

        #{inspect(other)}
    """
  end

  defp validate_type_name!(name, _option) when is_binary(name), do: :ok

  defp validate_type_name!(name, option) do
    raise ArgumentError, """
    invalid type name in #{inspect(option)} for build_field/1

    A type name has to be a string.

    Got:

        #{inspect(name)}
    """
  end

  defp validate_type_entry!(_name, entry, _option) when is_function(entry, 1),
    do: :ok

  defp validate_type_entry!(_name, {entry, opts}, _option)
       when is_function(entry, 1) and is_list(opts),
       do: :ok

  defp validate_type_entry!(name, entry, :types)
       when entry in [nil, :default] do
    if name in @built_in_types do
      :ok
    else
      raise ArgumentError, """
      invalid entry in :types for build_field/1

      `nil` and `:default` apply to built-in types only.

      Got:

          #{inspect(name)} => #{inspect(entry)}
      """
    end
  end

  defp validate_type_entry!(name, entry, option) do
    raise ArgumentError, """
    invalid entry in #{inspect(option)} for build_field/1

    An entry has to be a function component, `{component, group: true}`,
    `:default` or `nil`.

    Got:

        #{inspect(name)} => #{inspect(entry)}
    """
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @derived_from [
    :field,
    :id,
    :name,
    :value,
    :errors,
    :validations,
    :description,
    :multiple
  ]

  @doc false
  def prepare(
        %{field: %Phoenix.HTML.FormField{} = field} = assigns,
        gettext_module
      ) do
    errors =
      cond do
        errors = assigns[:errors] ->
          errors

        Phoenix.Component.used_input?(field) ->
          Enum.map(
            field.errors,
            &Doggo.translate_error(&1, gettext_module)
          )

        true ->
          []
      end

    id = assigns.id || field.id

    defaults = [
      errors: errors,
      validations: Form.input_validations(field.form, field.field),
      name: if(assigns.multiple, do: field.name <> "[]", else: field.name),
      value: field.value
    ]

    assign_input(
      assigns,
      id,
      errors,
      for(
        {key, value} <- defaults,
        not is_map_key(assigns, key),
        do: {key, value}
      )
    )
  end

  def prepare(assigns, _gettext_module) when not is_map_key(assigns, :field) do
    errors = Map.get(assigns, :errors) || []
    id = assigns[:id] || assigns[:name]

    assign_input(assigns, id, errors,
      errors: errors,
      validations: Map.get(assigns, :validations) || []
    )
  end

  def prepare(assigns, _gettext_module), do: assigns

  @impl true
  def template(opts) do
    custom_types =
      opts
      |> types!()
      |> Map.filter(fn {_name, entry} -> entry not in [nil, :default] end)

    {:case, meta, [subject, [do: clauses]]} = builtin_case()

    quote do
      var!(assigns) =
        unquote(__MODULE__).prepare(
          var!(assigns),
          unquote(Keyword.get(opts, :gettext_module))
        )

      unquote(
        {:case, meta,
         [
           subject,
           [
             do:
               custom_clauses(custom_types) ++
                 Enum.reject(
                   clauses,
                   &(clause_type(&1) in Map.keys(custom_types))
                 )
           ]
         ]}
      )
    end
  end

  # credo:disable-for-next-line
  defp builtin_case do
    # credo:disable-for-next-line
    quote do
      case var!(assigns) do
        %{type: "checkbox"} ->
          var!(assigns) = unquote(__MODULE__).assign_checked(var!(assigns))

          ~H"""
          <div
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            data-invalid={@errors != []}
            {@data_attrs}
          >
            <Doggo.Components.Field.label
              required={@validations[:required] || false}
              required_text={Doggo.build(:required_text)}
              optional_text={Doggo.build(:optional_text)}
              class={Doggo.build(:base_class, "-checkbox")}
              base_class={Doggo.build(:base_class)}
              gettext_module={Doggo.build(:gettext_module)}
            >
              <input :if={@hidden_input} type="hidden" name={@name} value="false" />
              <input
                type="checkbox"
                name={@name}
                id={@id}
                value={@checked_value}
                checked={@checked}
                aria-describedby={@describedby}
                aria-errormessage={@errormessage}
                aria-invalid={@errors != [] && "true"}
                {@validations}
                {@rest}
              />
              {@label}
            </Doggo.Components.Field.label>
            <Doggo.Components.Field.field_errors
              for={@id}
              errors={@errors}
              base_class={Doggo.build(:base_class)}
            />
            <Doggo.Components.Field.field_description
              :if={@description != []}
              for={@id}
              base_class={Doggo.build(:base_class)}
            >
              {render_slot(@description)}
            </Doggo.Components.Field.field_description>
          </div>
          """

        %{type: "checkbox-group"} ->
          ~H"""
          <div
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            data-invalid={@errors != []}
            {@data_attrs}
          >
            <fieldset class={Doggo.build(:base_class, "-checkbox-group")}>
              <legend>
                {@label}
                <Doggo.Components.Field.required_optional_mark
                  required={@validations[:required] || false}
                  required_text={Doggo.build(:required_text)}
                  optional_text={Doggo.build(:optional_text)}
                  base_class={Doggo.build(:base_class)}
                  gettext_module={Doggo.build(:gettext_module)}
                />
              </legend>
              <Doggo.Components.Field.field_description
                :if={@description != []}
                for={@id}
                base_class={Doggo.build(:base_class)}
              >
                {render_slot(@description)}
              </Doggo.Components.Field.field_description>
              <div>
                <input type="hidden" name={@name <> "[]"} value="" />
                <Doggo.Components.Field.checkbox
                  :for={option <- @options}
                  option={option}
                  name={@name}
                  id={@id}
                  value={@value}
                  errors={@errors}
                  description={@description}
                  describedby={@describedby}
                  errormessage={@errormessage}
                  base_class={Doggo.build(:base_class)}
                />
              </div>
            </fieldset>
            <Doggo.Components.Field.field_errors
              for={@id}
              errors={@errors}
              base_class={Doggo.build(:base_class)}
            />
          </div>
          """

        %{type: "hidden", value: value} when is_list(value) ->
          ~H"""
          <input :for={value <- @value} type="hidden" name={@name <> "[]"} value={value} />
          """

        %{type: "hidden"} ->
          ~H"""
          <input type="hidden" name={@name} value={@value} />
          """

        %{type: "radio-group"} ->
          ~H"""
          <div
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            data-invalid={@errors != []}
            {@data_attrs}
          >
            <fieldset class={Doggo.build(:base_class, "-radio-group")}>
              <legend>
                {@label}
                <Doggo.Components.Field.required_optional_mark
                  required={@validations[:required] || false}
                  required_text={Doggo.build(:required_text)}
                  optional_text={Doggo.build(:optional_text)}
                  base_class={Doggo.build(:base_class)}
                  gettext_module={Doggo.build(:gettext_module)}
                />
              </legend>
              <Doggo.Components.Field.field_description
                :if={@description != []}
                for={@id}
                base_class={Doggo.build(:base_class)}
              >
                {render_slot(@description)}
              </Doggo.Components.Field.field_description>
              <div>
                <Doggo.Components.RadioGroup.radio
                  :for={option <- @options}
                  option={option}
                  name={@name}
                  id={@id}
                  value={@value}
                  errors={@errors}
                  description={@description}
                  required={@validations[:required] || false}
                  base_class={Doggo.build(:base_class)}
                />
              </div>
            </fieldset>
            <Doggo.Components.Field.field_errors
              for={@id}
              errors={@errors}
              base_class={Doggo.build(:base_class)}
            />
          </div>
          """

        %{type: "select"} ->
          var!(assigns) =
            unquote(__MODULE__).assign_select_value(var!(assigns))

          ~H"""
          <div
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            data-invalid={@errors != []}
            {@data_attrs}
          >
            <Doggo.Components.Field.label
              for={@id}
              required={@validations[:required] || false}
              required_text={Doggo.build(:required_text)}
              optional_text={Doggo.build(:optional_text)}
              base_class={Doggo.build(:base_class)}
              visually_hidden={@hide_label}
              gettext_module={Doggo.build(:gettext_module)}
            >
              {@label}
            </Doggo.Components.Field.label>
            <div class={Doggo.build(:base_class, "-select")} data-multiple={@multiple}>
              <select
                name={@name}
                id={@id}
                multiple={@multiple}
                aria-describedby={@describedby}
                aria-errormessage={@errormessage}
                aria-invalid={@errors != [] && "true"}
                {@validations}
                {@rest}
              >
                <option :if={@prompt} value="">{@prompt}</option>
                <Doggo.Components.Field.option
                  :for={option <- @options}
                  selected_values={@value}
                  option={option}
                />
              </select>
            </div>
            <Doggo.Components.Field.field_errors
              for={@id}
              errors={@errors}
              base_class={Doggo.build(:base_class)}
            />
            <Doggo.Components.Field.field_description
              :if={@description != []}
              for={@id}
              base_class={Doggo.build(:base_class)}
            >
              {render_slot(@description)}
            </Doggo.Components.Field.field_description>
          </div>
          """

        %{type: "switch"} ->
          var!(assigns) = unquote(__MODULE__).assign_checked(var!(assigns))

          ~H"""
          <div
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            data-invalid={@errors != []}
            {@data_attrs}
          >
            <Doggo.Components.Field.label
              required={@validations[:required] || false}
              required_text={Doggo.build(:required_text)}
              optional_text={Doggo.build(:optional_text)}
              class={Doggo.build(:base_class, "-switch")}
              base_class={Doggo.build(:base_class)}
              gettext_module={Doggo.build(:gettext_module)}
            >
              <span class={Doggo.build(:base_class, "-switch-label")}>{@label}</span>
              <input :if={@hidden_input} type="hidden" name={@name} value="false" />
              <input
                type="checkbox"
                role="switch"
                name={@name}
                id={@id}
                value={@checked_value}
                checked={@checked}
                aria-describedby={@describedby}
                aria-errormessage={@errormessage}
                aria-invalid={@errors != [] && "true"}
                {@validations}
                {@rest}
              />
              <span class={Doggo.build(:base_class, "-switch-state")}>
                <span
                  class={Doggo.build(:base_class, "-switch-state-on")}
                  aria-hidden="true"
                >
                  {@on_text}
                </span>
                <span
                  class={Doggo.build(:base_class, "-switch-state-off")}
                  aria-hidden="true"
                >
                  {@off_text}
                </span>
              </span>
            </Doggo.Components.Field.label>
            <Doggo.Components.Field.field_errors
              for={@id}
              errors={@errors}
              base_class={Doggo.build(:base_class)}
            />
            <Doggo.Components.Field.field_description
              :if={@description != []}
              for={@id}
              base_class={Doggo.build(:base_class)}
            >
              {render_slot(@description)}
            </Doggo.Components.Field.field_description>
          </div>
          """

        %{type: "textarea"} ->
          ~H"""
          <div
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            data-invalid={@errors != []}
            {@data_attrs}
          >
            <Doggo.Components.Field.label
              for={@id}
              required={@validations[:required] || false}
              required_text={Doggo.build(:required_text)}
              optional_text={Doggo.build(:optional_text)}
              base_class={Doggo.build(:base_class)}
              visually_hidden={@hide_label}
              gettext_module={Doggo.build(:gettext_module)}
            >
              {@label}
            </Doggo.Components.Field.label>
            <textarea
              name={@name}
              id={@id}
              aria-describedby={@describedby}
              aria-errormessage={@errormessage}
              aria-invalid={@errors != [] && "true"}
              {@validations}
              {@rest}
            ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
            <Doggo.Components.Field.field_errors
              for={@id}
              errors={@errors}
              base_class={Doggo.build(:base_class)}
            />
            <Doggo.Components.Field.field_description
              :if={@description != []}
              for={@id}
              base_class={Doggo.build(:base_class)}
            >
              {render_slot(@description)}
            </Doggo.Components.Field.field_description>
          </div>
          """

        _ ->
          var!(assigns) = unquote(__MODULE__).assign_addon(var!(assigns))

          ~H"""
          <div
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            data-invalid={@errors != []}
            {@data_attrs}
          >
            <Doggo.Components.Field.label
              for={@id}
              required={@validations[:required] || false}
              required_text={Doggo.build(:required_text)}
              optional_text={Doggo.build(:optional_text)}
              base_class={Doggo.build(:base_class)}
              visually_hidden={@hide_label}
              gettext_module={Doggo.build(:gettext_module)}
            >
              {@label}
            </Doggo.Components.Field.label>
            <div class={Doggo.build(:base_class, "-input-wrapper")} data-addon={@addon}>
              <input
                name={@name}
                id={@id}
                list={@options && "#{@id}_datalist"}
                type={@type}
                value={@type != "file" && Doggo.normalize_value(@type, @value)}
                multiple={@type == "file" && @multiple}
                aria-describedby={@describedby}
                aria-errormessage={@errormessage}
                aria-invalid={@errors != [] && "true"}
                {@validations}
                {@rest}
              />
              <div
                :if={@addon_left != []}
                class={Doggo.build(:base_class, "-input-addon-left")}
              >
                {render_slot(@addon_left)}
              </div>
              <div
                :if={@addon_right != []}
                class={Doggo.build(:base_class, "-input-addon-right")}
              >
                {render_slot(@addon_right)}
              </div>
            </div>
            <datalist :if={@options} id={"#{@id}_datalist"}>
              <Doggo.Components.Field.option :for={option <- @options} option={option} />
            </datalist>
            <Doggo.Components.Field.field_errors
              for={@id}
              errors={@errors}
              base_class={Doggo.build(:base_class)}
            />
            <Doggo.Components.Field.field_description
              :if={@description != []}
              for={@id}
              base_class={Doggo.build(:base_class)}
            >
              {render_slot(@description)}
            </Doggo.Components.Field.field_description>
          </div>
          """
      end
    end
  end

  defp custom_clauses(custom_types) when custom_types == %{}, do: []

  defp custom_clauses(custom_types) do
    Enum.flat_map(custom_types, fn {type, entry} ->
      {input, group?} = custom_entry(entry)
      template = if group?, do: custom_group(), else: custom_control()

      {:case, _, [_, [do: clauses]]} =
        quote do
          case var!(assigns) do
            %{type: unquote(type)} ->
              var!(assigns) =
                Doggo.assign_derived(
                  var!(assigns),
                  [input: unquote(Macro.escape(input))],
                  [:type]
                )

              unquote(template)
          end
        end

      clauses
    end)
  end

  defp clause_type({:->, _, [[{:when, _, [pattern, _]}], _]}),
    do: clause_type({:->, [], [[pattern], nil]})

  defp clause_type({:->, _, [[{:%{}, _, fields}], _]}), do: fields[:type]
  defp clause_type(_clause), do: nil

  defp custom_group do
    quote do
      ~H"""
      <div
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        data-invalid={@errors != []}
        {@data_attrs}
      >
        <fieldset class={"#{Doggo.build(:base_class)}-#{@type}"}>
          <legend>
            {@label}
            <Doggo.Components.Field.required_optional_mark
              required={@validations[:required] || false}
              required_text={Doggo.build(:required_text)}
              optional_text={Doggo.build(:optional_text)}
              base_class={Doggo.build(:base_class)}
              gettext_module={Doggo.build(:gettext_module)}
            />
          </legend>
          <Doggo.Components.Field.field_description
            :if={@description != []}
            for={@id}
            base_class={Doggo.build(:base_class)}
          >
            {render_slot(@description)}
          </Doggo.Components.Field.field_description>
          {@input.(Doggo.Components.Field.input_assigns(assigns))}
        </fieldset>
        <Doggo.Components.Field.field_errors
          for={@id}
          errors={@errors}
          base_class={Doggo.build(:base_class)}
        />
      </div>
      """
    end
  end

  defp custom_control do
    quote do
      ~H"""
      <div
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        data-invalid={@errors != []}
        {@data_attrs}
      >
        <Doggo.Components.Field.label
          for={@id}
          required={@validations[:required] || false}
          required_text={Doggo.build(:required_text)}
          optional_text={Doggo.build(:optional_text)}
          base_class={Doggo.build(:base_class)}
          visually_hidden={@hide_label}
          gettext_module={Doggo.build(:gettext_module)}
        >
          {@label}
        </Doggo.Components.Field.label>
        {@input.(Doggo.Components.Field.input_assigns(assigns))}
        <Doggo.Components.Field.field_errors
          for={@id}
          errors={@errors}
          base_class={Doggo.build(:base_class)}
        />
        <Doggo.Components.Field.field_description
          :if={@description != []}
          for={@id}
          base_class={Doggo.build(:base_class)}
        >
          {render_slot(@description)}
        </Doggo.Components.Field.field_description>
      </div>
      """
    end
  end

  defp custom_entry({input, opts}),
    do: {input, Keyword.get(opts, :group, false)}

  defp custom_entry(input), do: {input, false}

  @doc false
  def assign_select_value(assigns) do
    Doggo.assign_derived(
      assigns,
      [
        value:
          assigns[:value]
          |> List.wrap()
          |> Enum.map(&Phoenix.HTML.html_escape/1)
      ],
      [:value]
    )
  end

  @doc false
  def assign_addon(
        %{addon_left: addon_left, addon_right: addon_right} = assigns
      ) do
    addon =
      case {addon_left, addon_right} do
        {[], []} -> nil
        {_, []} -> "left"
        {[], _} -> "right"
        {_, _} -> "left right"
      end

    Doggo.assign_derived(assigns, [addon: addon], [:addon_left, :addon_right])
  end

  defp assign_input(assigns, id, errors, defaults) do
    Doggo.assign_derived(
      assigns,
      [
        field: nil,
        id: id,
        describedby:
          Doggo.input_aria_describedby(id, assigns.description, errors),
        errormessage: Doggo.input_aria_errormessage(id, errors)
      ] ++ defaults,
      @derived_from
    )
  end

  @doc false
  def assign_checked(assigns) when is_map_key(assigns, :checked), do: assigns

  def assign_checked(assigns) do
    Doggo.assign_derived(
      assigns,
      [checked: Form.normalize_value("checkbox", assigns[:value])],
      [:value]
    )
  end

  attr :for, :string, required: true, doc: "The ID of the input."
  attr :base_class, :string, required: true
  slot :inner_block, required: true

  @doc false
  def field_description(%{for: for} = assigns) do
    assigns = assign(assigns, :id, Doggo.field_description_id(for))

    ~H"""
    <div id={@id} class={"#{@base_class}-description"}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :for, :string, required: true, doc: "The ID of the input."
  attr :base_class, :string, required: true
  attr :errors, :list, required: true, doc: "A list of errors as strings."

  @doc false
  def field_errors(%{for: for} = assigns) do
    assigns = assign(assigns, :id, Doggo.field_errors_id(for))

    ~H"""
    <ul id={@id} class={"#{@base_class}-errors"} aria-live="polite">
      <li :for={error <- @errors}>{error}</li>
    </ul>
    """
  end

  attr :for, :string, default: nil, doc: "The ID of the input."
  attr :class, :string, default: nil
  attr :base_class, :string, required: true
  attr :gettext_module, :atom, required: true
  attr :required, :boolean, default: false

  attr :required_text, :any,
    required: true,
    doc: """
    Sets the presentational text or symbol to mark an input as required.
    """

  attr :optional_text, :any,
    required: true,
    doc: """
    Sets the presentational text or symbol to mark an input as optional.
    """

  attr :visually_hidden, :boolean,
    default: false,
    doc: """
    Adds a "data-visually-hidden" attribute to the `<label>`.
    """

  slot :inner_block, required: true

  @doc false
  def label(assigns) do
    ~H"""
    <label for={@for} class={@class} data-visually-hidden={@visually_hidden}>
      {render_slot(@inner_block)}
      <.required_optional_mark
        required={@required}
        required_text={@required_text}
        optional_text={@optional_text}
        base_class={@base_class}
        gettext_module={@gettext_module}
      />
    </label>
    """
  end

  # Inputs are announced as required by screen readers if the `required`
  # attribute is set. This makes this mark purely visual. `aria-hidden="true"`
  # is added so that screen readers don't announce redundant information.

  attr :required, :boolean, required: true
  attr :required_text, :any, required: true
  attr :optional_text, :any, required: true
  attr :base_class, :string, required: true
  attr :gettext_module, :atom, required: true

  @doc false
  def required_optional_mark(
        %{
          required: true,
          required_text: required_text,
          gettext_module: gettext_module
        } = assigns
      )
      when is_binary(required_text) do
    required_text =
      if gettext_module,
        # credo:disable-for-next-line
        do: apply(Gettext, :gettext, [gettext_module, required_text]),
        else: required_text

    assigns = assign(assigns, :required_text, required_text)

    ~H"""
    <span class={"#{@base_class}-required-mark"} aria-hidden="true">
      {@required_text}
    </span>
    """
  end

  def required_optional_mark(
        %{
          required: false,
          optional_text: optional_text,
          gettext_module: gettext_module
        } = assigns
      )
      when is_binary(optional_text) do
    optional_text =
      if gettext_module,
        # credo:disable-for-next-line
        do: apply(Gettext, :gettext, [gettext_module, optional_text]),
        else: optional_text

    assigns = assign(assigns, :optional_text, optional_text)

    ~H"""
    <span class={"#{@base_class}-optional-mark"} aria-hidden="true">
      {@optional_text}
    </span>
    """
  end

  def required_optional_mark(assigns) do
    ~H""
  end

  attr :option, :any, required: true
  attr :selected_values, :list, default: []

  @doc false
  def option(%{option: :hr} = assigns) do
    ~H"""
    <hr />
    """
  end

  def option(%{option: {group_label, options}} = assigns)
      when is_list(options) or is_map(options) do
    assigns =
      assigns
      |> assign(:group_label, group_label)
      |> assign(:options, options)

    ~H"""
    <optgroup label={@group_label}>
      <.option
        :for={option <- @options}
        option={option}
        selected_values={@selected_values}
      />
    </optgroup>
    """
  end

  def option(%{option: {key, value}} = assigns) do
    assigns =
      assigns
      |> assign(:key, key)
      |> assign(:value, Phoenix.HTML.html_escape(value))

    ~H"""
    <option value={@value} selected={@value in @selected_values}>
      {@key}
    </option>
    """
  end

  def option(%{option: options} = assigns) when is_map(options) do
    ~H"""
    <.option
      :for={{key, value} <- @option}
      option={{key, value}}
      selected_values={@selected_values}
    />
    """
  end

  def option(%{option: [{:key, key}, {:value, value}]} = assigns) do
    assigns =
      assigns
      |> assign(:key, key)
      |> assign(:value, value)

    ~H"""
    <.option option={{@key, @value}} selected_values={@selected_values} />
    """
  end

  def option(%{option: options} = assigns) when is_list(options) do
    {option_key, options} = Keyword.pop(options, :key)

    option_key ||
      raise ArgumentError,
            "expected :key key when building <option> from keyword list: #{inspect(options)}"

    {option_value, options} = Keyword.pop(options, :value)

    option_value ||
      raise ArgumentError,
            "expected :value key when building <option> from keyword list: #{inspect(options)}"

    value = Phoenix.HTML.html_escape(option_value)
    {selected, extra} = Keyword.pop(options, :selected)

    Doggo.diagnostic do
      if extra[:description] do
        raise ArgumentError, """
        Invalid :description on a select option

        The `:description` option is not supported for `type="select"`.
        """
      end
    end

    assigns =
      assign(assigns,
        key: option_key,
        value: value,
        selected: selected || value in assigns.selected_values,
        extra: extra
      )

    ~H"""
    <option value={@value} selected={@selected} {@extra}>{@key}</option>
    """
  end

  def option(%{option: _key_and_value} = assigns) do
    ~H"""
    <.option option={{@option, @option}} selected_values={@selected_values} />
    """
  end

  @doc false
  def checkbox(%{option_value: _} = assigns) do
    assigns =
      assigns
      |> Map.put_new(:option_extra, [])
      |> Doggo.describe_option()

    ~H"""
    <label class={"#{@base_class}-checkbox"}>
      <input
        type="checkbox"
        name={@name <> "[]"}
        id={@id <> "_" <> Doggo.id_fragment(@option_value)}
        value={@option_value}
        checked={Doggo.checked?(@option_value, @value)}
        aria-describedby={@describedby}
        aria-errormessage={@errormessage}
        aria-invalid={@errors != [] && "true"}
        {@option_extra}
      />
      {@label}
    </label>
    <span
      :if={@option_description}
      id={@option_description_id}
      class={"#{@base_class}-option-description"}
    >
      {@option_description}
    </span>
    """
  end

  def checkbox(%{option: option} = assigns) when is_list(option) do
    {label, value, description, extra} = Doggo.option_from_keyword(option)

    assigns
    |> assign(
      label: label,
      option_value: value,
      option_description: description,
      option_extra: extra,
      option: nil
    )
    |> checkbox()
  end

  def checkbox(%{option: {group_label, options}} = assigns)
      when is_list(options) or is_map(options) do
    assigns = assign(assigns, group_label: group_label, options: options)

    ~H"""
    <fieldset class={"#{@base_class}-option-group"}>
      <legend>{@group_label}</legend>
      <.checkbox
        :for={option <- @options}
        option={option}
        name={@name}
        id={@id}
        value={@value}
        errors={@errors}
        description={@description}
        describedby={@describedby}
        errormessage={@errormessage}
        base_class={@base_class}
      />
    </fieldset>
    """
  end

  def checkbox(%{option: {option_label, option_value}} = assigns) do
    assigns
    |> assign(label: option_label, option_value: option_value, option: nil)
    |> checkbox()
  end

  def checkbox(%{option: option_value} = assigns) do
    assigns
    |> assign(
      label: Doggo.humanize(option_value),
      option_value: option_value,
      option: nil
    )
    |> checkbox()
  end

  @doc false
  def input_assigns(assigns) do
    assigns
    |> Map.take([
      :__changed__,
      :describedby,
      :errormessage,
      :id,
      :multiple,
      :name,
      :options,
      :prompt,
      :rest,
      :type,
      :validations,
      :value
    ])
    |> Map.put(:invalid, assigns.errors != [])
  end
end
