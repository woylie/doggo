defmodule Doggo do
  @moduledoc """
  Collection of Phoenix Components.
  """

  use Phoenix.Component

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS

  @fills [:solid, :outline, :text]
  @ratios [
    {1, 1},
    {3, 2},
    {2, 3},
    {4, 3},
    {3, 4},
    {5, 4},
    {4, 5},
    {16, 9},
    {9, 16}
  ]
  @shapes [:circle, :pill]
  @sizes [:small, :normal, :medium, :large]
  @skeleton_types [
    :text_line,
    :text_block,
    :image,
    :circle,
    :rectangle,
    :square
  ]
  @variants [:primary, :secondary, :info, :success, :warning, :danger]

  ## Components

  @doc false
  def slide_label(n), do: "Slide #{n}"

  @doc false
  def truncate_datetime(nil, _), do: nil
  def truncate_datetime(v, nil), do: v
  def truncate_datetime(v, :minute), do: %{v | second: 0, microsecond: {0, 0}}

  def truncate_datetime(%DateTime{} = dt, precision) do
    DateTime.truncate(dt, precision)
  end

  def truncate_datetime(%NaiveDateTime{} = dt, precision) do
    NaiveDateTime.truncate(dt, precision)
  end

  def truncate_datetime(%Time{} = t, precision) do
    Time.truncate(t, precision)
  end

  @doc false
  def shift_zone(%DateTime{} = dt, tz) when is_binary(tz) do
    DateTime.shift_zone!(dt, tz)
  end

  def shift_zone(v, _), do: v

  @doc false
  def datetime_attr(%DateTime{} = dt) do
    DateTime.to_iso8601(dt)
  end

  def datetime_attr(%NaiveDateTime{} = dt) do
    NaiveDateTime.to_iso8601(dt)
  end

  # don't add title attribute if no title formatter is set
  @doc false
  def time_title_attr(_, nil), do: nil
  def time_title_attr(v, fun) when is_function(fun, 1), do: fun.(v)

  @doc false
  def to_date(%Date{} = d), do: d
  def to_date(%DateTime{} = dt), do: DateTime.to_date(dt)
  def to_date(%NaiveDateTime{} = dt), do: NaiveDateTime.to_date(dt)
  def to_date(nil), do: nil

  @doc false
  def to_time(%Time{} = t), do: t
  def to_time(%DateTime{} = dt), do: DateTime.to_time(dt)
  def to_time(%NaiveDateTime{} = dt), do: NaiveDateTime.to_time(dt)
  def to_time(nil), do: nil

  @doc """
  Renders a frame with an aspect ratio for images or videos.

  This component is used within the `image/1` component.

  ## Example

  Rendering an image with the aspect ratio 4:3.

  ```heex
  <Doggo.frame ratio={{4, 3}}>
    <img src="image.png" alt="An example image illustrating the usage." />
  </Doggo.frame>
  ```

  Rendering an image as a circle.

  ```heex
  <Doggo.frame circle>
    <img src="image.png" alt="An example image illustrating the usage." />
  </Doggo.frame>
  ```
  """
  @doc type: :component
  @doc since: "0.2.0"

  attr :ratio, :any, values: [nil | @ratios], default: nil
  attr :circle, :boolean, default: false

  slot :inner_block

  def frame(assigns) do
    ~H"""
    <div class={["frame", ratio_class(@ratio), @circle && shape_class(:circle)]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc false
  def label_placement_class(:hidden), do: nil
  def label_placement_class(:left), do: "has-text-left"
  def label_placement_class(:right), do: "has-text-right"

  @doc """
  Renders an image with an optional caption.

  ## Example

  ```heex
  <Doggo.image
    src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
    alt="A dog wearing a colorful poncho walks down a fashion show runway."
    ratio={{16, 9}}
  >
    <:caption>
      Spotlight on canine couture: A dog fashion show where four-legged models
      dazzle the runway with the latest in pet apparel.
    </:caption>
  </Doggo.image>
  ```
  """
  @doc type: :component
  @doc since: "0.2.0"

  attr :src, :string, required: true, doc: "The URL of the image to render."

  attr :srcset, :any,
    default: nil,
    doc: """
    A set of image URLs in different sizes. Can be passed as a string or a map.

    For example, this map:

        %{
          "1x" => "images/image-1x.jpg",
          "2x" => "images/image-2x.jpg"
        }

    Will result in this `srcset`:

        "images/image-1x.jpg 1x, images/image-2x.jpg 2x"

    See https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/srcset.
    """

  attr :sizes, :string,
    default: nil,
    doc: """
    Specifies media conditions for the image widths, if the `srcset` attribute
    uses intrinsic widths.

    See https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/sizes.
    """

  attr :alt, :string,
    required: true,
    doc: """
    A text description of the image for screen reader users and those with slow
    internet. Effective alt text should concisely capture the image's essence
    and function, considering its context within the content. Aim for clarity
    and inclusivity without repeating information already conveyed by
    surrounding text, and avoid starting with "Image of" as screen readers
    automatically announce image presence.
    """

  attr :width, :integer, default: nil
  attr :height, :integer, default: nil
  attr :loading, :string, values: ["eager", "lazy"], default: "lazy"
  attr :ratio, :any, values: [nil | @ratios], default: nil

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."
  slot :caption

  def image(assigns) do
    ~H"""
    <figure class={["image" | List.wrap(@class)]} {@rest}>
      <.frame ratio={@ratio}>
        <img
          src={@src}
          width={@width}
          height={@height}
          alt={@alt}
          loading={@loading}
          srcset={build_srcset(@srcset)}
          sizes={@sizes}
        />
      </.frame>
      <figcaption :if={@caption != []}><%= render_slot(@caption) %></figcaption>
    </figure>
    """
  end

  defp build_srcset(nil), do: nil
  defp build_srcset(srcset) when is_binary(srcset), do: srcset

  defp build_srcset(%{} = srcset) do
    Enum.map_join(srcset, ", ", fn {width_or_density, url} ->
      "#{url} #{width_or_density}"
    end)
  end

  @doc """
  Renders a form field including input, label, errors, and description.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  In addition to all HTML input types, the following type values are also
  supported:

  - `"select"` - For `<select>` elements.

  ## Gettext

  To translate field errors using Gettext, configure your Gettext module in
  `config/config.exs`.

      config :doggo, gettext: MyApp.Gettext

  Alternatively, pass the Gettext module as an attribute:

  ```heex
  <Doggo.input field={@form[:name]} gettext={MyApp.Gettext} />
  ```

  ## Label positioning

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

  ## Examples

  ```heex
  <Doggo.input field={@form[:name]} />
  ```

  ```heex
  <Doggo.input field={@form[:email]} type="email" />
  ```

  ### Radio group and checkbox group

  The `radio-group` and `checkbox-group` types allow you to easily render groups
  of radio buttons or checkboxes with a single component invocation. The
  `options` attribute is required for these types and has the same format as
  the options for the `select` type, except that options may not be nested.

  ```heex
  <Doggo.input
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
  @doc type: :form
  @doc since: "0.1.0"

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

  attr :required_text, :atom,
    doc: """
    The presentational text or symbol to be added to labels of required inputs.

    This option can also be set globally:

        config :doggo, required_text: "required"
    """

  attr :required_title, :atom,
    doc: """
    The `title` attribute for the `required_text`.

    This option can also be set globally:

        config :doggo, required_title: "required"
    """

  slot :description, doc: "A field description to render underneath the input."

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

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    gettext_module =
      Map.get(assigns, :gettext, Application.get_env(:doggo, :gettext))

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(
      :errors,
      fn -> Enum.map(errors, &translate_error(&1, gettext_module)) end
    )
    |> assign_new(
      :required_text,
      fn -> Application.get_env(:doggo, :required_text, "*") end
    )
    |> assign_new(
      :required_title,
      fn -> Application.get_env(:doggo, :required_title, "required") end
    )
    |> assign_new(:validations, fn ->
      Form.input_validations(field.form, field.field)
    end)
    |> assign_new(:name, fn ->
      if assigns.multiple, do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <.label required={@validations[:required] || false} class="checkbox">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          name={@name}
          id={@id}
          value={@checked_value}
          checked={@checked}
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        />
        <%= @label %>
      </.label>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "checkbox-group"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <fieldset class="checkbox-group">
        <legend>
          <%= @label %>
          <.required_mark
            :if={@validations[:required]}
            text={@required_text}
            title={@required_title}
          />
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
          />
        </div>
      </fieldset>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "radio-group"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <fieldset class="radio-group">
        <legend>
          <%= @label %>
          <.required_mark
            :if={@validations[:required]}
            text={@required_text}
            title={@required_title}
          />
        </legend>
        <div>
          <Doggo.Components.radio
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
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "switch"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <.label required={@validations[:required] || false} class="switch">
        <span class="switch-label"><%= @label %></span>
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          role="switch"
          name={@name}
          id={@id}
          value={@checked_value}
          checked={@checked}
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
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
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        required_title={@required_title}
        visually_hidden={@hide_label}
      >
        <%= @label %>
      </.label>
      <div class={["select", @multiple && "is-multiple"]}>
        <select
          name={@name}
          id={@id}
          multiple={@multiple}
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        >
          <option :if={@prompt} value=""><%= @prompt %></option>
          <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
        </select>
      </div>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        required_title={@required_title}
        visually_hidden={@hide_label}
      >
        <%= @label %>
      </.label>
      <textarea
        name={@name}
        id={@id}
        aria-describedby={input_aria_describedby(@id, @description)}
        aria-errormessage={input_aria_errormessage(@id, @errors)}
        aria-invalid={@errors != [] && "true"}
        {@validations}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "hidden", value: values} = assigns) when is_list(values) do
    ~H"""
    <input :for={value <- @value} type="hidden" name={@name <> "[]"} value={value} />
    """
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" name={@name} value={@value} />
    """
  end

  def input(assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        required_title={@required_title}
        visually_hidden={@hide_label}
      >
        <%= @label %>
      </.label>
      <div class={[
        "input-wrapper",
        @addon_left != [] && "has-addon-left",
        @addon_right != [] && "has-addon-right"
      ]}>
        <input
          name={@name}
          id={@id}
          list={@options && "#{@id}_datalist"}
          type={@type}
          value={normalize_value(@type, @value)}
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        />
        <div :if={@addon_left != []} class="input-addon-left">
          <%= render_slot(@addon_left) %>
        </div>
        <div :if={@addon_right != []} class="input-addon-right">
          <%= render_slot(@addon_right) %>
        </div>
      </div>
      <datalist :if={@options} id={"#{@id}_datalist"}>
        <.option :for={option <- @options} option={option} />
      </datalist>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
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

  defp normalize_value("date", %struct{} = value)
       when struct in [Date, NaiveDateTime, DateTime] do
    <<date::10-binary, _::binary>> = struct.to_string(value)
    {:safe, date}
  end

  defp normalize_value("date", <<date::10-binary, _::binary>>) do
    {:safe, date}
  end

  defp normalize_value("date", _), do: ""
  defp normalize_value(type, value), do: Form.normalize_value(type, value)

  @doc false
  def input_aria_describedby(_, []), do: nil
  def input_aria_describedby(id, _), do: field_description_id(id)

  @doc false
  def input_aria_errormessage(_, []), do: nil
  def input_aria_errormessage(id, _), do: field_errors_id(id)

  defp field_error_class([]), do: nil
  defp field_error_class(_), do: "has-errors"

  defp checkbox(%{option_value: _} = assigns) do
    ~H"""
    <.label class="checkbox">
      <input
        type="checkbox"
        name={@name <> "[]"}
        id={@id <> "_#{@option_value}"}
        value={@option_value}
        checked={checked?(@option_value, @value)}
        aria-describedby={input_aria_describedby(@id, @description)}
        aria-errormessage={input_aria_errormessage(@id, @errors)}
        aria-invalid={@errors != [] && "true"}
      />
      <%= @label %>
    </.label>
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
      label: humanize(option_value),
      option_value: option_value,
      option: nil
    )
    |> checkbox()
  end

  @doc false
  def checked?(option, value) when is_list(value) do
    Phoenix.HTML.html_escape(option) in Enum.map(
      value,
      &Phoenix.HTML.html_escape/1
    )
  end

  def checked?(option, value) do
    Phoenix.HTML.html_escape(option) == Phoenix.HTML.html_escape(value)
  end

  @doc """
  Renders the label for an input.

  ## Example

  ```heex
  <Doggo.label for="name" required>
    Name
  </Doggo.label>
  ```
  """
  @doc type: :form
  @doc since: "0.1.0"

  attr :for, :string, default: nil, doc: "The ID of the input."

  attr :required, :boolean,
    default: false,
    doc: "If set to `true`, a 'required' mark is rendered."

  attr :required_text, :any,
    default: "*",
    doc: """
    Sets the presentational text or symbol to mark an input as required.
    """

  attr :required_title, :any,
    default: "required",
    doc: """
    Sets the `title` attribute of the required mark.
    """

  attr :visually_hidden, :boolean,
    default: false,
    doc: """
    Adds an "is-visually-hidden" class to the `<label>`.
    """

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class={[@visually_hidden && "is-visually-hidden" | List.wrap(@class)]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <.required_mark :if={@required} title={@required_title} text={@required_text} />
    </label>
    """
  end

  attr :text, :string, default: "*"
  attr :title, :string, default: "required"

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
    <span :if={@text} class="label-required" aria-hidden="true" title={@title}>
      <%= @text %>
    </span>
    """
  end

  @doc """
  Renders the errors for an input.

  ## Example

  ```heex
  <Doggo.field_errors for="name" errors={["too many characters"]} />
  ```
  """
  @doc type: :form
  @doc since: "0.1.0"

  attr :for, :string, required: true, doc: "The ID of the input."
  attr :errors, :list, required: true, doc: "A list of errors as strings."

  def field_errors(assigns) do
    ~H"""
    <ul :if={@errors != []} id={field_errors_id(@for)} class="field-errors">
      <li :for={error <- @errors}><%= error %></li>
    </ul>
    """
  end

  defp field_errors_id(id) when is_binary(id), do: "#{id}_errors"

  @doc """
  Renders the description of an input.

  ## Example

  ```heex
  <Doggo.field_description for="name">
    max. 100 characters
  </Doggo.field_description>
  ```
  """
  @doc type: :form
  @doc since: "0.1.0"

  attr :for, :string, required: true, doc: "The ID of the input."
  slot :inner_block, required: true

  def field_description(assigns) do
    ~H"""
    <div id={field_description_id(@for)} class="field-description">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp field_description_id(id) when is_binary(id), do: "#{id}_description"

  defp translate_error({msg, opts}, nil) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  defp translate_error({msg, opts}, gettext_module)
       when is_atom(gettext_module) do
    if count = opts[:count] do
      # credo:disable-for-next-line
      apply(Gettext, :dngettext, [
        gettext_module,
        "errors",
        msg,
        msg,
        count,
        opts
      ])
    else
      # credo:disable-for-next-line
      apply(Gettext, :dgettext, [gettext_module, "errors", msg, opts])
    end
  end

  @doc """
  Use the field group component to visually group multiple inputs in a form.

  This component is intended for styling purposes and does not provide semantic
  grouping. For semantic grouping of related form elements, use the `<fieldset>`
  and `<legend>` HTML elements instead.

  ## Examples

  Visual grouping of inputs:

  ```heex
  <Doggo.field_group>
    <Doggo.input field={@form[:given_name]} label="Given name" />
    <Doggo.input field={@form[:family_name]} label="Family name"/>
  </Doggo.field_group>
  ```

  Semantic grouping (for reference):

  ```heex
  <fieldset>
    <legend>Personal Information</legend>
    <Doggo.input field={@form[:given_name]} label="Given name" />
    <Doggo.input field={@form[:family_name]} label="Family name"/>
  </fieldset>
  ```
  """
  @doc type: :form
  @doc since: "0.3.0"

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :inner_block, required: true

  def field_group(assigns) do
    ~H"""
    <div class={["field-group" | List.wrap(@class)]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  ## Helpers

  @doc false
  def humanize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> humanize()
  end

  def humanize(s) when is_binary(s) do
    if String.ends_with?(s, "_id") do
      s |> binary_part(0, byte_size(s) - 3) |> to_titlecase()
    else
      to_titlecase(s)
    end
  end

  defp to_titlecase(s) do
    s
    |> String.replace("_", " ")
    |> :string.titlecase()
  end

  ## JS functions

  @doc """
  Hides the modal with the given ID.

  ## Example

  ```heex
  <.link phx-click={hide_modal("pet-modal")}>hide</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.remove_attribute("open", to: "##{id}")
    |> JS.set_attribute({"aria-modal", "false"}, to: "##{id}")
    |> JS.pop_focus()
  end

  @doc """
  Shows the modal with the given ID.

  ## Example

  ```heex
  <.link phx-click={show_modal("pet-modal")}>show</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.push_focus()
    |> JS.set_attribute({"open", "true"}, to: "##{id}")
    |> JS.set_attribute({"aria-modal", "true"}, to: "##{id}")
    |> JS.focus_first(to: "##{id}-content")
  end

  @doc """
  Shows the tab with the given index of the `tabs/1` component with the given
  ID.

  ## Example

      Doggo.show_tab("my-tabs", 2)
  """
  @doc type: :js
  @doc since: "0.5.0"

  def show_tab(js \\ %JS{}, id, index)
      when is_binary(id) and is_integer(index) do
    other_tabs = "##{id} [role='tab']:not(##{id}-tab-#{index})"
    other_panels = "##{id} [role='tabpanel']:not(##{id}-panel-#{index})"

    js
    |> JS.set_attribute({"aria-selected", "true"}, to: "##{id}-tab-#{index}")
    |> JS.set_attribute({"tabindex", "0"}, to: "##{id}-tab-#{index}")
    |> JS.remove_attribute("hidden", to: "##{id}-panel-#{index}")
    |> JS.set_attribute({"aria-selected", "false"}, to: other_tabs)
    |> JS.set_attribute({"tabindex", "-1"}, to: other_tabs)
    |> JS.set_attribute({"hidden", "hidden"}, to: other_panels)
  end

  @doc false
  def toggle_accordion_section(id, index)
      when is_binary(id) and is_integer(index) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"},
      to: "##{id}-trigger-#{index}"
    )
    |> JS.toggle_attribute({"hidden", "hidden"},
      to: "##{id}-section-#{index}"
    )
  end

  @doc false
  def toggle_disclosure(target_id) when is_binary(target_id) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"})
    |> JS.toggle_attribute({"hidden", "hidden"}, to: "##{target_id}")
  end

  ## Modifier classes

  @doc """
  Takes a modifier attribute value and returns a CSS class name.

  This function is used as a default for the `class_name_fun` option.

  ## Example

      iex> modifier_class_name("large")
      "is-large"
  """
  @spec modifier_class_name(String.t()) :: String.t()
  def modifier_class_name(value) when is_binary(value), do: "is-#{value}"

  for fill <- @fills do
    str = fill |> to_string() |> String.replace("_", "-")
    defp fill_class(unquote(fill)), do: "is-#{unquote(str)}"
  end

  for {w, h} <- @ratios do
    defp ratio_class({unquote(w), unquote(h)}) do
      "is-#{unquote(w)}-by-#{unquote(h)}"
    end
  end

  defp ratio_class(nil), do: nil

  for size <- @sizes do
    str = size |> to_string() |> String.replace("_", "-")
    defp size_class(unquote(size)), do: "is-#{unquote(str)}"
  end

  for shape <- @shapes do
    str = shape |> to_string() |> String.replace("_", "-")
    defp shape_class(unquote(shape)), do: "is-#{unquote(str)}"
  end

  defp shape_class(nil), do: nil

  for type <- @skeleton_types do
    str = type |> to_string() |> String.replace("_", "-")
    defp skeleton_type_class(unquote(type)), do: "is-#{unquote(str)}"
  end

  for variant <- @variants do
    str = variant |> to_string() |> String.replace("_", "-")
    defp variant_class(unquote(variant)), do: "is-#{unquote(str)}"
  end

  defp variant_class(nil), do: nil

  @doc false
  def fills, do: @fills

  @doc false
  def ratios, do: @ratios

  @doc false
  def shapes, do: @shapes

  @doc false
  def sizes, do: @sizes

  @doc false
  def skeleton_types, do: @skeleton_types

  @doc false
  def variants, do: @variants

  @doc false
  def modifier_classes do
    %{
      fills: Enum.map(fills(), &fill_class/1),
      ratios: Enum.map(ratios(), &ratio_class/1),
      shapes: Enum.map(shapes(), &shape_class/1),
      sizes: Enum.map(sizes(), &size_class/1),
      skeleton_types: Enum.map(skeleton_types(), &skeleton_type_class/1),
      variants: Enum.map(variants(), &variant_class/1)
    }
  end

  @doc false
  def ensure_label!(%{label: s, labelledby: nil}, _, _) when is_binary(s) do
    :ok
  end

  def ensure_label!(%{label: nil, labelledby: s}, _, _) when is_binary(s) do
    :ok
  end

  def ensure_label!(_, component, example_label) do
    raise Doggo.InvalidLabelError,
      component: component,
      example_label: example_label
  end
end
