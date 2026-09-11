defmodule Doggo.Components.Combobox do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @search_debounce 300

  @impl true
  def doc do
    """
    Renders a text input with a popup that allows users to select a value from
    a list of suggestions.
    """
  end

  @impl true
  def usage do
    """
    With simple values:

    ```heex
    <.combobox
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      options={[
        "Labrador Retriever",
        "German Shepherd",
        "Golden Retriever",
        "French Bulldog",
        "Bulldog"
      ]}
    />
    ```

    With label/value pairs:

    ```heex
    <.combobox
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      options={[
        {"Labrador Retriever", "labrador"},
        {"German Shepherd", "german_shepherd"},
        {"Golden Retriever", "golden_retriever"},
        {"French Bulldog", "french_bulldog"},
        {"Bulldog", "bulldog"}
      ]}
    />
    ```

    With descriptions and disabled option:

    ```heex
    <.combobox
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      options={[
        [key: "Labrador Retriever", value: "labrador", description: "Friendly and outgoing"],
        [key: "German Shepherd", value: "german_shepherd", description: "Confident and smart"],
        [key: "Bulldog", value: "bulldog", description: "Docile and willful", disabled: true]
      ]}
    />
    ```
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - Showing/hiding suggestions
      - Filtering suggestions
      - Selecting a value
      - Focus management
      - Keyboard support
      """,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-input-wrapper",
      "#{base_class}-option-description",
      "#{base_class}-option-free-text",
      "#{base_class}-option-group",
      "#{base_class}-option-group-label",
      "#{base_class}-option-label",
      "#{base_class}-option-term",
      "#{base_class}-toggle"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true, doc: "Sets the DOM ID for the input."

      attr :name, :string,
        required: true,
        doc: "Sets the name for the text input."

      attr :value, :string,
        default: nil,
        doc: """
        The current input value. The display value for the text input is derived
        by finding the given value in the list of options.
        """

      attr :display_value, :string,
        default: nil,
        doc: """
        The input value for the current value.

        Defaults to the label of the option matching `value` and falls back to
        the `value` if no option matches.

        Set this attribute if the value may not be among the options, for
        example if the options are loaded dynamically from the server based on
        the search term, as opposed to passing a fixed set of options.
        """

      attr :list_label, :string,
        required: true,
        doc: """
        Sets the aria label for the list box. For example, if the combobox allows
        the user to select a country, the list label could be `"Countries"`. The
        value should start with an uppercase letter and be localized.
        """

      attr :options, :list,
        required: true,
        doc: """
        A list of available options.

        The format is the same as the one accepted by the `select`,
        `"radio-group"`, and `"checkbox-group"` types of the `field` component.
        See also `Phoenix.HTML.Form.options_for_select/2`.

        - A primitive value is used as both label and value.
        - In a 2-tuple, the first element is the label and the second is the
          input value.
        - A map results in one option per key/value pair.
        - `:hr` renders a separator between options.

        You can also group options:

            options={[{"Retrievers", [{"Golden Retriever", "golden"}]}]}

        An option can also be written as a keyword list with these keys:

        - `:key` (required) - the label
        - `:value` (required) - the input value
        - `:description` (optional) - rendered under the label
        - `:disabled` (optional) - renders `aria-disabled`, and the option is
          skipped by the arrow keys and cannot be selected

        Example:

            options={[[key: "Golden Retriever", value: "golden", description: "Friendly"]]}
        """

      attr :free_text, :boolean,
        default: false,
        doc: """
        If `true`, users can submit a free text value that is not among the
        options.

        Requires `free_text_label`.
        """

      attr :free_text_label, :string,
        default: nil,
        doc: """
        A label for the option to submit the typed text, for example
        `"Add breed"`. Required when `free_text` is set.
        """

      attr :on_search, :any,
        default: nil,
        doc: """
        An event name as a string or a `Phoenix.LiveView.JS` command to emit
        when the user types. Use this for filtering options on the server side.

        If set, the component adds a `phx-change` attribute to the text input
        and the hook stops filtering. The search is debounced by
        #{unquote(@search_debounce)} ms. You can override the default by passing
        the `phx-debounce` attribute.

        If not set, the hook filters the passed options on the client side, and
        the search is not debounced by default.

        To use this attribute, the input must be inside a form, or else
        LiveView raises.
        """

      attr :rest, :global,
        default: %{autocomplete: "off"},
        include:
          ~w(autocomplete disabled form maxlength minlength pattern placeholder
         readonly required size),
        doc: """
        Any additional HTML attributes. These are set on the text input, not on
        the wrapper element.

        `disabled` and `form` are set on the hidden input as well.
        """
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(%{name: name, options: options, value: value} = assigns) do
    ensure_free_text_label!(assigns)

    {options, _counters} = normalize_options(options, {1, 1})

    value = value && to_string(value)

    {shared, rest} = Map.split(assigns.rest, [:disabled, :form])

    rest =
      if assigns.on_search do
        Map.put_new(rest, :"phx-debounce", @search_debounce)
      else
        rest
      end

    search_value = display_text(assigns.display_value, options, value)

    assigns =
      assign(assigns,
        options: options,
        rest: rest,
        search_name: search_name(name),
        value: value,
        search_value: search_value,
        shared_rest: shared
      )

    ~H"""
    <div
      id={"#{@id}-combobox"}
      class={@class}
      phx-hook="Doggo.Combobox"
      data-filter={@on_search && "server"}
      {@data_attrs}
    >
      <div class={"#{@base_class}-input-wrapper"}>
        <input
          id={@id}
          type="text"
          role="combobox"
          name={@search_name}
          value={@search_value}
          aria-autocomplete="list"
          aria-expanded="false"
          aria-controls={"#{@id}-listbox"}
          phx-change={@on_search}
          {@rest}
          {@shared_rest}
        />
        <button
          id={"#{@id}-button"}
          type="button"
          class={"#{@base_class}-toggle"}
          tabindex="-1"
          aria-label={@list_label}
          aria-expanded="false"
          aria-controls={"#{@id}-listbox"}
        >
          ▼
        </button>
      </div>
      <div id={"#{@id}-listbox"} role="listbox" aria-label={@list_label} hidden>
        <.combobox_entry
          :for={entry <- @options}
          entry={entry}
          id={@id}
          base_class={@base_class}
          value={@value}
        />
        <div
          :if={@free_text}
          id={"#{@id}-option-free-text"}
          role="option"
          class={"#{@base_class}-option-free-text"}
          aria-selected="false"
          data-free-text
          hidden
        >
          <span class={"#{@base_class}-option-label"}>{@free_text_label}</span>
          <span class={"#{@base_class}-option-term"}></span>
        </div>
      </div>
      <input
        type="hidden"
        id={"#{@id}-value"}
        name={@name}
        value={@value}
        {@shared_rest}
      />
    </div>
    """
  end

  defp search_name(name) do
    base = String.replace_suffix(name, "[]", "")

    if String.ends_with?(base, "]") do
      String.replace_suffix(base, "]", "_search]")
    else
      base <> "_search"
    end
  end

  defp display_text(nil, options, value),
    do: option_label(options, value) || value

  defp display_text(display_value, _options, _value), do: display_value

  defp combobox_entry(%{entry: :separator} = assigns) do
    ~H"""
    <hr />
    """
  end

  # The group label is a visible element referenced by `aria-labelledby`, and
  # the options sit directly inside the group, following the grouped listbox
  # example of the ARIA Authoring Practices.
  defp combobox_entry(%{entry: %{group: _}} = assigns) do
    ~H"""
    <div
      role="group"
      class={"#{@base_class}-option-group"}
      aria-labelledby={"#{@id}-group-#{@entry.index}"}
    >
      <span
        id={"#{@id}-group-#{@entry.index}"}
        class={"#{@base_class}-option-group-label"}
      >
        {@entry.group}
      </span>
      <.combobox_entry
        :for={entry <- @entry.options}
        entry={entry}
        id={@id}
        base_class={@base_class}
        value={@value}
      />
    </div>
    """
  end

  defp combobox_entry(assigns) do
    ~H"""
    <div
      id={"#{@id}-option-#{@entry.index}"}
      role="option"
      aria-selected={to_string(@entry.value == @value)}
      aria-disabled={@entry.disabled && "true"}
      data-value={@entry.value}
    >
      <span class={"#{@base_class}-option-label"}>{@entry.label}</span>
      <span
        :if={@entry.description}
        class={"#{@base_class}-option-description"}
      >
        {@entry.description}
      </span>
    </div>
    """
  end

  defp option_label(options, value) do
    Enum.find_value(options, fn
      %{value: ^value, label: label} -> label
      %{options: options} -> option_label(options, value)
      _ -> nil
    end)
  end

  defp normalize_options(options, counters) do
    Enum.flat_map_reduce(options, counters, &normalize_option/2)
  end

  defp normalize_option(:hr, counters), do: {[:separator], counters}

  defp normalize_option({group_label, options}, {option_no, group_no})
       when is_list(options) or is_map(options) do
    {options, counters} = normalize_options(options, {option_no, group_no + 1})

    {[%{group: group_label, index: group_no, options: options}], counters}
  end

  defp normalize_option(option, counters) when is_map(option) do
    normalize_options(option, counters)
  end

  defp normalize_option(option, counters) when is_list(option) do
    {label, value, description, extra} = Doggo.option_from_keyword(option)
    {disabled, extra} = Keyword.pop(extra, :disabled, false)
    ensure_no_extra_keys!(extra, option)

    build_option(label, value, description, disabled, counters)
  end

  defp normalize_option({label, value}, counters) do
    build_option(label, value, nil, false, counters)
  end

  defp normalize_option(option, _counters) when is_tuple(option) do
    raise ArgumentError, """
    unsupported option for .combobox

    An option must be one of:

    - a primitive value
    - a {label, value} tuple
    - a keyword list with at least :key and :value
    - a {group_label, options} tuple for a group of options

    Got:

        #{inspect(option)}
    """
  end

  defp normalize_option(option, counters) do
    build_option(option, option, nil, false, counters)
  end

  defp build_option(label, value, description, disabled, {option_no, group_no}) do
    option = %{
      index: option_no,
      label: label,
      value: value && to_string(value),
      description: description,
      disabled: disabled
    }

    {[option], {option_no + 1, group_no}}
  end

  defp ensure_free_text_label!(%{free_text: true, free_text_label: label})
       when not is_binary(label) or label == "" do
    raise ArgumentError, """
    missing free_text_label for .combobox

    A combobox with free_text enabled requires the free_text_label attribute to
    be set.

        <.combobox free_text free_text_label="Add breed" ... />
    """
  end

  defp ensure_free_text_label!(_), do: :ok

  defp ensure_no_extra_keys!([], _option), do: :ok

  defp ensure_no_extra_keys!(extra, option) do
    raise ArgumentError, """
    unsupported option keys for .combobox

    An option can have the keys :key, :value, :description and :disabled.

    Unsupported keys:

        #{inspect(Keyword.keys(extra))}

    In this option:

        #{inspect(option)}
    """
  end
end
