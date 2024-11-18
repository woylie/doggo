defmodule Doggo.Components.Field do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

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
    - `:gettext_module` - If set, errors are automatically translated using this
      module. This only works if the `:field` attribute is set. Without it,
      errors passed to the component are rendered unchanged.
    - `:addon_left_class` - This class is added to the input wrapper if the
      `:addon_left` slot is used.
    - `:addon_right_class` - This class is added to the input wrapper if the
      `:addon_right` slot is used.
    - `:visually_hidden_class` - This class is added to labels if `:hide_label`
      is set to `true`.
    """
  end

  @impl true
  def usage do
    """
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

    To translate field errors using Gettext, set the `gettext_module` option
    when building the component:

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

    The `radio-group` and `checkbox-group` types allow you to easily render groups
    of radio buttons or checkboxes with a single component invocation. The
    `options` attribute is required for these types and has the same format as
    the options for the `select` type, except that options may not be nested.

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
  def config do
    [
      type: :form,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [],
      extra: [
        gettext_module: nil,
        addon_left_class: "has-addon-left",
        addon_right_class: "has-addon-right",
        visually_hidden_class: "is-visually-hidden"
      ]
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-description",
      "#{base_class}-errors",
      "#{base_class}-input-addon-left",
      "#{base_class}-input-addon-right",
      "#{base_class}-input-wrapper"
    ]
  end

  @impl true
  def attrs_and_slots do
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
        Adds an "is-visually-hidden" class to the `<label>`. This option does not
        apply to checkbox and radio inputs.
        """

      attr :value, :any

      attr :type, :string,
        default: "text",
        values: ~w(checkbox checkbox-group color date datetime-local email file
         hidden month number password range radio radio-group search select
         switch tel text textarea time url week)

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

      attr :on_text, :string,
        default: "On",
        doc: "The state text for a switch when on."

      attr :off_text, :string,
        default: "Off",
        doc: "The state text for a switch when off."

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

        See `Phoenix.HTML.Form.options_for_select/2` for the format. Note that only
        the select supports nested options.
        """

      attr :multiple, :boolean,
        default: false,
        doc: """
        Sets the `multiple` attribute on a select element to allow selecting
        multiple options.
        """

      attr :rest, :global,
        include:
          ~w(accept autocomplete capture cols disabled form list max maxlength min
         minlength multiple passwordrules pattern placeholder readonly required
         rows size step)

      attr :gettext, :atom,
        doc: """
        The Gettext module to use for translating error messages. This option can
        also be set globally, see above.
        """

      attr :required_text, :string,
        doc: """
        The presentational text or symbol to be added to labels of required inputs.

        This option can also be set globally:

            config :doggo, required_text: "required"
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

  @impl true
  def init_block(_opts, extra) do
    addon_left_class = Keyword.fetch!(extra, :addon_left_class)
    addon_right_class = Keyword.fetch!(extra, :addon_right_class)
    visually_hidden_class = Keyword.fetch!(extra, :visually_hidden_class)
    gettext_module = Keyword.get(extra, :gettext_module)

    quote do
      var!(assigns) =
        assign(
          var!(assigns),
          gettext_module: unquote(gettext_module),
          addon_left_class: unquote(addon_left_class),
          addon_right_class: unquote(addon_right_class),
          visually_hidden_class: unquote(visually_hidden_class)
        )
    end
  end

  @impl true
  def render(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors =
      cond do
        errors = assigns[:errors] ->
          errors

        Phoenix.Component.used_input?(field) ->
          Enum.map(
            field.errors,
            &Doggo.translate_error(&1, assigns.gettext_module)
          )

        true ->
          []
      end

    id = assigns.id || field.id

    assigns
    |> assign(field: nil, id: id)
    |> assign(:class, assigns.class ++ [field_error_class(errors)])
    |> assign(
      :describedby,
      Doggo.input_aria_describedby(id, assigns.description)
    )
    |> assign(:errormessage, Doggo.input_aria_errormessage(id, errors))
    |> assign_new(:errors, fn -> errors end)
    |> assign_new(
      :required_text,
      fn -> Application.get_env(:doggo, :required_text, "*") end
    )
    |> assign_new(:validations, fn ->
      Phoenix.HTML.Form.input_validations(field.form, field.field)
    end)
    |> assign_new(:name, fn ->
      if assigns.multiple, do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> render()
  end

  def render(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={@class}>
      <.label
        required={@validations[:required] || false}
        class="checkbox"
        visually_hidden_class={@visually_hidden_class}
      >
        <input type="hidden" name={@name} value="false" />
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
        <%= @label %>
      </.label>
      <.field_errors for={@id} errors={@errors} base_class={@base_class} />
      <.field_description
        :if={@description != []}
        for={@id}
        base_class={@base_class}
      >
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def render(%{type: "checkbox-group"} = assigns) do
    ~H"""
    <div class={@class}>
      <fieldset class="checkbox-group">
        <legend>
          <%= @label %>
          <.required_mark :if={@validations[:required]} text={@required_text} />
        </legend>
        <div>
          <input type="hidden" name={@name <> "[]"} value="" />
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
          />
        </div>
      </fieldset>
      <.field_errors for={@id} errors={@errors} base_class={@base_class} />
      <.field_description
        :if={@description != []}
        for={@id}
        base_class={@base_class}
      >
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def render(%{type: "hidden", value: values} = assigns)
      when is_list(values) do
    ~H"""
    <input :for={value <- @value} type="hidden" name={@name <> "[]"} value={value} />
    """
  end

  def render(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" name={@name} value={@value} />
    """
  end

  def render(%{type: "radio-group"} = assigns) do
    ~H"""
    <div class={@class}>
      <fieldset class="radio-group">
        <legend>
          <%= @label %>
          <.required_mark :if={@validations[:required]} text={@required_text} />
        </legend>
        <div>
          <Doggo.Components.RadioGroup.radio
            :for={option <- @options}
            option={option}
            name={@name}
            id={@id}
            value={@value}
            errors={@errors}
            description={@description}
          />
        </div>
      </fieldset>
      <.field_errors for={@id} errors={@errors} base_class={@base_class} />
      <.field_description
        :if={@description != []}
        for={@id}
        base_class={@base_class}
      >
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def render(%{type: "select"} = assigns) do
    ~H"""
    <div class={@class}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        visually_hidden={@hide_label}
        visually_hidden_class={@visually_hidden_class}
      >
        <%= @label %>
      </.label>
      <div class={["select", @multiple && "is-multiple"]}>
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
          <option :if={@prompt} value=""><%= @prompt %></option>
          <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
        </select>
      </div>
      <.field_errors for={@id} errors={@errors} base_class={@base_class} />
      <.field_description
        :if={@description != []}
        for={@id}
        base_class={@base_class}
      >
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def render(%{type: "switch"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={@class}>
      <.label
        required={@validations[:required] || false}
        class="switch"
        visually_hidden_class={@visually_hidden_class}
      >
        <span class="switch-label"><%= @label %></span>
        <input type="hidden" name={@name} value="false" />
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
        <span class="switch-state">
          <span
            class={if @checked, do: "switch-state-on", else: "switch-state-off"}
            aria-hidden="true"
          >
            <%= if @checked do %>
              <%= @on_text %>
            <% else %>
              <%= @off_text %>
            <% end %>
          </span>
        </span>
      </.label>
      <.field_errors for={@id} errors={@errors} base_class={@base_class} />
      <.field_description
        :if={@description != []}
        for={@id}
        base_class={@base_class}
      >
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def render(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={@class}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        visually_hidden={@hide_label}
        visually_hidden_class={@visually_hidden_class}
      >
        <%= @label %>
      </.label>
      <textarea
        name={@name}
        id={@id}
        aria-describedby={@describedby}
        aria-errormessage={@errormessage}
        aria-invalid={@errors != [] && "true"}
        {@validations}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.field_errors for={@id} errors={@errors} base_class={@base_class} />
      <.field_description
        :if={@description != []}
        for={@id}
        base_class={@base_class}
      >
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class={@class}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        visually_hidden={@hide_label}
        visually_hidden_class={@visually_hidden_class}
      >
        <%= @label %>
      </.label>
      <div class={[
        "#{@base_class}-input-wrapper",
        @addon_left != [] && @addon_left_class,
        @addon_right != [] && @addon_right_class
      ]}>
        <input
          name={@name}
          id={@id}
          list={@options && "#{@id}_datalist"}
          type={@type}
          value={Doggo.normalize_value(@type, @value)}
          aria-describedby={@describedby}
          aria-errormessage={@errormessage}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        />
        <div :if={@addon_left != []} class={"#{@base_class}-input-addon-left"}>
          <%= render_slot(@addon_left) %>
        </div>
        <div :if={@addon_right != []} class={"#{@base_class}-input-addon-right"}>
          <%= render_slot(@addon_right) %>
        </div>
      </div>
      <datalist :if={@options} id={"#{@id}_datalist"}>
        <.option :for={option <- @options} option={option} />
      </datalist>
      <.field_errors for={@id} errors={@errors} base_class={@base_class} />
      <.field_description
        :if={@description != []}
        for={@id}
        base_class={@base_class}
      >
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  attr :for, :string, required: true, doc: "The ID of the input."
  attr :base_class, :string, required: true
  slot :inner_block, required: true

  defp field_description(%{for: for} = assigns) do
    assigns = assign(assigns, :id, Doggo.field_description_id(for))

    ~H"""
    <div id={@id} class={"#{@base_class}-description"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :for, :string, required: true, doc: "The ID of the input."
  attr :base_class, :string, required: true
  attr :errors, :list, required: true, doc: "A list of errors as strings."

  defp field_errors(%{for: for} = assigns) do
    assigns = assign(assigns, :id, Doggo.field_errors_id(for))

    ~H"""
    <ul :if={@errors != []} id={@id} class={"#{@base_class}-errors"}>
      <li :for={error <- @errors}><%= error %></li>
    </ul>
    """
  end

  attr :for, :string, default: nil, doc: "The ID of the input."
  attr :class, :string, default: nil

  attr :required, :boolean,
    default: false,
    doc: "If set to `true`, a 'required' mark is rendered."

  attr :required_text, :any,
    default: "*",
    doc: """
    Sets the presentational text or symbol to mark an input as required.
    """

  attr :visually_hidden, :boolean,
    default: false,
    doc: """
    Adds an "is-visually-hidden" class to the `<label>`.
    """

  attr :visually_hidden_class, :string, required: true

  slot :inner_block, required: true

  defp label(
         %{
           class: class,
           visually_hidden: visually_hidden,
           visually_hidden_class: visually_hidden_class
         } = assigns
       ) do
    class =
      if visually_hidden,
        do: [class, visually_hidden_class],
        else: class

    assigns = assign(assigns, :class, class)

    ~H"""
    <label for={@for} class={@class}>
      <%= render_slot(@inner_block) %>
      <.required_mark :if={@required} text={@required_text} />
    </label>
    """
  end

  # inputs are announced as required by screen readers if the `required`
  # attribute is set. This makes this mark purely visual. `aria-hidden="true"`
  # is added so that screen readers don't announce redundant information. The
  # title attribute has poor accessibility characteristics, but since this is
  # purely presentational, this is acceptable.
  # It is good practice to add a sentence explaining that fields marked with an
  # asterisk (*) are required to the form.
  # Alternatively, the word `required` might be used instead of an asterisk.
  defp required_mark(assigns) do
    ~H"""
    <span :if={@text} class="field-required-mark" aria-hidden="true" title={@title}>
      <%= @text %>
    </span>
    """
  end

  defp option(%{option: {label, value}} = assigns) do
    assigns = assign(assigns, label: label, value: value)

    ~H"""
    <option value={@value}><%= @label %></option>
    """
  end

  defp option(%{option: _} = assigns) do
    ~H"""
    <option value={@option}><%= @option %></option>
    """
  end

  defp checkbox(%{option_value: _} = assigns) do
    ~H"""
    <label class="checkbox">
      <input
        type="checkbox"
        name={@name <> "[]"}
        id={@id <> "_#{@option_value}"}
        value={@option_value}
        checked={Doggo.checked?(@option_value, @value)}
        aria-describedby={@describedby}
        aria-errormessage={@errormessage}
        aria-invalid={@errors != [] && "true"}
      />
      <%= @label %>
    </label>
    """
  end

  defp checkbox(%{option: {option_label, option_value}} = assigns) do
    assigns
    |> assign(label: option_label, option_value: option_value, option: nil)
    |> checkbox()
  end

  defp checkbox(%{option: option_value} = assigns) do
    assigns
    |> assign(
      label: Doggo.humanize(option_value),
      option_value: option_value,
      option: nil
    )
    |> checkbox()
  end

  defp field_error_class([]), do: nil
  defp field_error_class(_), do: "has-errors"
end
