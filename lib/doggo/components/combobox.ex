defmodule Doggo.Components.Combobox do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

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

    With label/value/description tuples:

    ```heex
    <.combobox
      id="dog-breed-selector"
      name="breed"
      list_label="Dog breeds"
      options={[
        {"Labrador Retriever", "labrador", "Friendly and outgoing"},
        {"German Shepherd", "german_shepherd", "Confident and smart"},
        {"Golden Retriever", "golden_retriever", "Intelligent and friendly"},
        {"French Bulldog", "french_bulldog", "Adaptable and playful"},
        {"Bulldog", "bulldog", "Docile and willful"}
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

        - If a list of primitive values is passed, each item serves as both the
          label and the input value.
        - If a list of 2-tuples is passed, the first tuple element serves as label
          and the second element serves as input value.
        - If a list of 3-tuples is passed, the third tuple element serves as
          an additional description.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
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

    options = Enum.map(options, &normalize_option/1)

    assigns =
      assign(assigns,
        options: options,
        search_name: search_name,
        search_value: option_label(options, value)
      )

    ~H"""
    <div class={@class} {@data_attrs} {@rest}>
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
          autocomplete="off"
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
      <ul id={"#{@id}-listbox"} role="listbox" aria-label={@list_label} hidden>
        <li
          :for={
            {{label, option_value, description}, index} <-
              Enum.with_index(@options, 1)
          }
          id={"#{@id}-option-#{index}"}
          role="option"
          aria-selected={to_string(option_value == @value)}
          data-value={option_value}
        >
          <span class={"#{@base_class}-option-label"}>{label}</span>
          <span :if={description} class={"#{@base_class}-option-description"}>
            {description}
          </span>
        </li>
      </ul>
      <input type="hidden" id={"#{@id}-value"} name={@name} value={@value} />
    </div>
    """
  end

  defp option_label(options, value) do
    Enum.find_value(options, fn
      {label, ^value, _} -> label
      _ -> nil
    end)
  end

  defp normalize_option({label, value}), do: {label, value, nil}

  defp normalize_option({label, value, description}),
    do: {label, value, description}

  defp normalize_option(option), do: {option, option, nil}
end
