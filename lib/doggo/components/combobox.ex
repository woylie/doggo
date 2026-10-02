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
  def usage(%{name: name}) do
    """
    ## Options

    With simple values:

    ```heex
    <.#{name}
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
    <.#{name}
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

    With descriptions and a disabled option:

    ```heex
    <.#{name}
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

    ## Label

    The component does not render a label by itself, so you must render one
    yourself. This is important for accessibility: without it the text input has
    no accessible name, and a screen reader announces it as a combobox without
    saying what is being chosen.

    The usual way is a `<label>` whose `for` attribute is the `id` you passed:

    ```heex
    <label for="dog-breed-selector">Breed</label>
    <.#{name}
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      options={@breeds}
    />
    ```

    If the name is already on the page, for example in the form of a heading,
    you can set `aria-labelledby` to the ID of that element instead:

    ```heex
    <h2 id="breed-heading">Breed</h2>
    <.#{name}
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      aria-labelledby="breed-heading"
      options={@breeds}
    />
    ```

    `aria-labelledby` and `aria-label` are global attributes that are set on
    the text input, which is the element that needs the label.

    By contrast, `list_label` labels the listbox and the button that opens it.
    It describes the list of options, not the field.

    ## In a form

    To use the component in a form, you need to pass the `id`, `name`, and
    `value`, and add the label, description, and errors.

    ```heex
    <.form for={@form} phx-change="validate" phx-submit="save">
      <label for="dog-breed-selector">Breed</label>
      <.#{name}
        id="dog-breed-selector"
        name={@form[:breed].name}
        value={@form[:breed].value}
        list_label="Dog breeds"
        options={@breeds}
      />
    </.form>
    ```

    The component renders a hidden input with the given `name`. Its value is the
    selected option value, or, if a free text entry is selected, the entered
    value.

    The text input the user types uses the given name with a `_search` suffix.
    The submitted value is either the label of the selected option or
    the current search term. You can use this value to filter options on the
    server side, or otherwise ignore it.

    ## With a clear button

    If the `clearable` attribute is set, a clear button is rendered that
    unselects the current selection and clears the search term.

    ```heex
    <.#{name}
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      clearable
      clear_label="Clear breed"
      options={@breeds}
    />
    ```

    Both the toggle button and the clear button have default content that can
    be replaced with the build options `clear` and `toggle`:

    ```elixir
    build_combobox(
      clear: ~H|<Heroicon.x_mark />|,
      toggle: ~H|<Heroicon.chevron_down />|
    )
    ```

    ## With free text

    If the `free_text` attribute is set, the user can choose to submit an
    entered value that is not among the options.

    ```heex
    <.#{name}
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      free_text
      free_text_label="Add breed"
      options={@breeds}
    />
    ```

    ## With options loaded from the server

    Set `on_search` to filter on the server. If set, the hook stops filtering on
    the client side, and your handler receives the typed text as the `*_search`
    parameter described above.

    ```heex
    <.#{name}
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      options={@breeds}
      on_search="search-breeds"
    />
    ```

    ```elixir
    def handle_event("search-breeds", %{"breed_search" => term}, socket) do
      {:noreply, assign(socket, breeds: Dogs.search_breeds(term))}
    end
    ```

    Instead of an event name, you can also pass a `Phoenix.LiveView.JS` command.
    """
  end

  @impl true
  def keyboard do
    """
    - `Down` - open the listbox, or move to the next option. Opening moves to
      the selected option, or to the first one if nothing is selected.
    - `Up` - open the listbox at the last option, or move to the previous one.
    - `Alt` + `Down` - open the listbox without moving to an option.
    - `Alt` + `Up` - close the listbox, leaving the text as it is.
    - `Enter` - select the active option.
    - `Escape` - close the listbox and put the display value of the selection
      back in the input. With the listbox already closed and the display value
      unchanged, clear the selection.

    The combobox is a single tab stop. Focus stays on the text input and never
    moves into the listbox. The active option is tracked with
    `aria-activedescendant`. The toggle and the clear button are out of the tab
    order; keyboard users can use `Alt` + `Down` and `Alt` + `Up` for the
    toggle, and `Escape` for clearing.

    `Home`, `End`, `Left`, `Right`, `Backspace` and `Delete` are not intercepted
    and are reserved for the browser's text editing.
    """
  end

  @impl true
  def css_path do
    "components/combobox.css"
  end

  @impl true
  def builder_doc do
    """
    - `:clear` - The content of the clear button. Defaults to `nil`, which
      renders a multiplication sign. The accessible name comes from
      `clear_label`.
    - `:toggle` - The content of the button that opens the listbox. Defaults to
      `nil`, which renders a downwards-pointing triangle. The accessible name
      comes from `list_label`.

    Both take a remote capture of a function component or inline HEEx, such as
    `~H|<.icon name="x" />|`.
    """
  end

  @impl true
  def config do
    [
      type: :form,
      since: "0.6.0",
      maturity: :developing,
      maturity_note: """
      The semantics follow the ARIA Authoring Practices, and everything the
      combobox pattern asks for is implemented, including the keyboard support.

      The level stays at `:developing` because the API is new and has not been
      proven in production yet.
      """,
      extra: [clear: nil, toggle: nil],
      render_options: [clear: :content, toggle: :content],
      modifiers: []
    ]
  end

  @impl true
  def own_attributes do
    ["aria-controls": nil, "aria-expanded": nil, role: nil, type: nil]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-clear",
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
        doc: """
        Sets the name of the hidden input that submits the value. The name of
        the text input is the same name with the `_search` suffix.
        """

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
        Sets the aria label for the list box. For example, if the combobox
        allows the user to select a country, the list label could be
        `"Countries"`. The value should start with an uppercase letter and be
        localized.
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

      attr :clearable, :boolean,
        default: false,
        doc: """
        If `true`, a clear button is rendered.

        The button is hidden while there is nothing to clear. Pressing `Escape`
        on a closed listbox clears the selection whether or not the button is
        rendered.
        """

      attr :clear_label, :string,
        default: "Clear",
        doc: """
        Aria label for the clear button. This value should be translated to the
        language in which the rest of the page is displayed.
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
  def template(opts) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      Doggo.diagnostic do
        Doggo.ensure_name!(
          var!(assigns).list_label,
          unquote(name),
          "list_label"
        )

        Doggo.ensure_name!(
          var!(assigns).clear_label,
          unquote(name),
          "clear_label"
        )

        Doggo.ensure_optional_name!(
          var!(assigns).free_text_label,
          unquote(name),
          "free_text_label"
        )

        unquote(__MODULE__).ensure_free_text_label!(var!(assigns))
        unquote(__MODULE__).ensure_option_keys!(var!(assigns).options)
      end

      var!(assigns) = unquote(__MODULE__).prepare(var!(assigns))

      ~H"""
      <div
        id={"#{@id}-combobox"}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        phx-hook="Doggo.Combobox"
        data-filter={@on_search && "server"}
        {@data_attrs}
      >
        <div class={Doggo.build(:base_class, "-input-wrapper")}>
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
            :if={@clearable}
            id={"#{@id}-clear"}
            type="button"
            class={Doggo.build(:base_class, "-clear")}
            tabindex="-1"
            data-clear
            aria-label={@clear_label}
            hidden={@value in [nil, ""]}
          >
            <Doggo.control_content
              content={Doggo.build(:clear)}
              modifiers={@data_attrs.data}
              label="×"
            />
          </button>
          <button
            id={"#{@id}-button"}
            type="button"
            class={Doggo.build(:base_class, "-toggle")}
            tabindex="-1"
            aria-label={@list_label}
            aria-expanded="false"
            aria-controls={"#{@id}-listbox"}
          >
            <Doggo.control_content
              content={Doggo.build(:toggle)}
              modifiers={@data_attrs.data}
              label="▼"
            />
          </button>
        </div>
        <div id={"#{@id}-listbox"} role="listbox" aria-label={@list_label} hidden>
          <Doggo.Components.Combobox.combobox_entry
            :for={entry <- @options}
            entry={entry}
            id={@id}
            base_class={Doggo.build(:base_class)}
            selected={@selected}
          />
          <div
            :if={@free_text}
            id={"#{@id}-option-free-text"}
            role="option"
            class={Doggo.build(:base_class, "-option-free-text")}
            aria-selected="false"
            data-free-text
            hidden
          >
            <span class={Doggo.build(:base_class, "-option-label")} dir="auto">{@free_text_label}</span>
            <span class={Doggo.build(:base_class, "-option-term")} dir="auto"></span>
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
  end

  @doc false
  def prepare(%{name: name, options: options, value: value} = assigns) do
    {options, _counters} = normalize_options(options, {1, 1})

    value = value && to_string(value)
    selected = selected_index(options, value)

    {shared, rest} = Map.split(assigns.rest, [:disabled, :form])

    rest =
      if assigns.on_search do
        Map.put_new(rest, :"phx-debounce", @search_debounce)
      else
        rest
      end

    search_value = display_text(assigns.display_value, options, value)

    assigns
    |> Doggo.assign_derived(
      [
        options: options,
        search_name: search_name(name),
        selected: selected,
        value: value,
        search_value: search_value
      ],
      [:name, :options, :value, :display_value]
    )
    |> Doggo.assign_derived(
      [rest: rest, shared_rest: shared],
      [:rest, :on_search]
    )
  end

  defp search_name(name) do
    base = String.replace_suffix(name, "[]", "")

    if String.ends_with?(base, "]") do
      String.replace_suffix(base, "]", "_search]")
    else
      base <> "_search"
    end
  end

  defp display_text(nil, options, value) do
    option_label(options, value) || value
  end

  defp display_text(display_value, _options, _value), do: display_value

  # A listbox allows only `option` and `group` as accessibility children in
  # ARIA 1.2 and in the 1.3 draft. Axe fails a separator as a chil
  # (dequelabs/axe-core#3938). Hide it from accessibility tree.
  @doc false
  def combobox_entry(%{entry: :separator} = assigns) do
    ~H"""
    <hr aria-hidden="true" />
    """
  end

  # The group label is a visible element referenced by `aria-labelledby`, and
  # the options sit directly inside the group, following the grouped listbox
  # example of the ARIA Authoring Practices.
  def combobox_entry(%{entry: %{group: _}} = assigns) do
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
        selected={@selected}
      />
    </div>
    """
  end

  def combobox_entry(assigns) do
    ~H"""
    <div
      id={"#{@id}-option-#{@entry.index}"}
      role="option"
      aria-selected={to_string(@entry.index == @selected)}
      aria-disabled={@entry.disabled && "true"}
      data-value={@entry.value}
    >
      <span class={"#{@base_class}-option-label"} dir="auto">{@entry.label}</span>
      <span
        :if={@entry.description}
        class={"#{@base_class}-option-description"}
        dir="auto"
      >
        {@entry.description}
      </span>
    </div>
    """
  end

  defp selected_index(_options, nil), do: nil

  defp selected_index(options, value) do
    Enum.find_value(options, fn
      %{value: ^value, index: index} -> index
      %{options: options} -> selected_index(options, value)
      _ -> nil
    end)
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

    # Groups without options need to be hidden.
    if Enum.any?(options, &option?/1) do
      {[%{group: group_label, index: group_no, options: options}], counters}
    else
      {[], {option_no, group_no}}
    end
  end

  defp normalize_option(option, counters) when is_map(option) do
    normalize_options(option, counters)
  end

  defp normalize_option(option, counters) when is_list(option) do
    {label, value, description, extra} = Doggo.Form.option_from_keyword(option)
    {disabled, _extra} = Keyword.pop(extra, :disabled, false)

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
      value: to_string(value),
      description: description,
      disabled: disabled
    }

    {[option], {option_no + 1, group_no}}
  end

  defp option?(%{value: _}), do: true
  defp option?(%{options: options}), do: Enum.any?(options, &option?/1)
  defp option?(_), do: false

  @doc false
  def ensure_free_text_label!(%{free_text: true, free_text_label: label})
      when not is_binary(label) or label == "" do
    raise ArgumentError, """
    missing free_text_label for .combobox

    A combobox with free_text enabled requires the free_text_label attribute to
    be set.

        <.combobox free_text free_text_label="Add breed" ... />
    """
  end

  def ensure_free_text_label!(_), do: :ok

  @doc false
  def ensure_option_keys!(options) when is_list(options) or is_map(options) do
    Enum.each(options, &ensure_keys_of_option!/1)
  end

  def ensure_option_keys!(_options), do: :ok

  defp ensure_keys_of_option!({_group_label, options})
       when is_list(options) or is_map(options) do
    ensure_option_keys!(options)
  end

  defp ensure_keys_of_option!(option) when is_map(option) do
    ensure_option_keys!(option)
  end

  defp ensure_keys_of_option!(option) when is_list(option) do
    {_label, _value, _description, extra} =
      Doggo.Form.option_from_keyword(option)

    ensure_no_extra_keys!(Keyword.delete(extra, :disabled), option)
  end

  defp ensure_keys_of_option!(_option), do: :ok

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
