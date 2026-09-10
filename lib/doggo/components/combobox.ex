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
      "#{base_class}-option-label",
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

        An option can also be written as a keyword list with these keys:

        - `:key` (required) - the label
        - `:value` (required) - the input value
        - `:description` (optional) - rendered under the label
        - `:disabled` (optional) - renders `aria-disabled`, and the option is
          skipped by the arrow keys and cannot be selected

        Example:

            options={[[key: "Golden Retriever", value: "golden", description: "Friendly"]]}
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
    search_name =
      if String.ends_with?(name, "]"),
        do: "#{String.slice(name, 0..-2//1)}_search]",
        else: name <> "_search"

    options = Enum.flat_map(options, &normalize_option/1)

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
        search_name: search_name,
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
        <div
          :for={{option, index} <- Enum.with_index(@options, 1)}
          id={"#{@id}-option-#{index}"}
          role="option"
          aria-selected={to_string(option.value == @value)}
          aria-disabled={option.disabled && "true"}
          data-value={option.value}
        >
          <span class={"#{@base_class}-option-label"}>{option.label}</span>
          <span
            :if={option.description}
            class={"#{@base_class}-option-description"}
          >
            {option.description}
          </span>
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

  defp display_text(nil, options, value),
    do: option_label(options, value) || value

  defp display_text(display_value, _options, _value), do: display_value

  defp option_label(options, value) do
    Enum.find_value(options, fn
      %{value: ^value, label: label} -> label
      _ -> nil
    end)
  end

  defp normalize_option(option) when is_map(option) do
    Enum.flat_map(option, &normalize_option/1)
  end

  defp normalize_option(option) when is_list(option) do
    {label, value, description, extra} = Doggo.option_from_keyword(option)
    {disabled, extra} = Keyword.pop(extra, :disabled, false)
    ensure_no_extra_keys!(extra, option)

    build_option(label, value, description, disabled)
  end

  defp normalize_option({label, value}) do
    build_option(label, value, nil, false)
  end

  defp normalize_option(option) when is_tuple(option) do
    raise ArgumentError, """
    unsupported option for .combobox

    An option must be one of:

    - a primitive value
    - a {label, value}
    - a keyword list with at least :key and :value

    Got:

        #{inspect(option)}
    """
  end

  defp normalize_option(option) do
    build_option(option, option, nil, false)
  end

  defp build_option(label, value, description, disabled) do
    [
      %{
        label: label,
        value: value,
        description: description,
        disabled: disabled
      }
    ]
  end

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
