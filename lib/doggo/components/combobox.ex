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
      "#{base_class}-option-description",
      "#{base_class}-option-label"
    ]
  end

  @impl true
  def attrs_and_slots do
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

    search_value =
      Enum.find_value(options, fn
        ^value -> value
        {label, ^value} -> label
        {label, ^value, _} -> label
        _ -> nil
      end)

    assigns =
      assign(assigns,
        search_name: search_name,
        search_value: search_value
      )

    ~H"""
    <div class={@class} {@rest}>
      <div role="group">
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
          tabindex="-1"
          aria-label={@list_label}
          aria-expanded="false"
          aria-controls={"#{@id}-listbox"}
        >
          ▼
        </button>
      </div>
      <ul id={"#{@id}-listbox"} role="listbox" aria-label={@list_label} hidden>
        <.combobox_option
          :for={option <- @options}
          base_class={@base_class}
          option={option}
        />
      </ul>
      <input type="hidden" id={"#{@id}-value"} name={@name} value={@value} />
    </div>
    """
  end

  defp combobox_option(%{option: {label, value}} = assigns) do
    assigns = assign(assigns, label: label, value: value, option: nil)

    ~H"""
    <li role="option" data-value={@value}>
      <span class={"#{@base_class}-option-label"}><%= @label %></span>
    </li>
    """
  end

  defp combobox_option(%{option: {label, value, description}} = assigns) do
    assigns =
      assign(assigns,
        label: label,
        value: value,
        description: description,
        option: nil
      )

    ~H"""
    <li role="option" data-value={@value}>
      <span class={"#{@base_class}-option-label"}><%= @label %></span>
      <span class={"#{@base_class}-option-description"}><%= @description %></span>
    </li>
    """
  end

  defp combobox_option(assigns) do
    ~H"""
    <li role="option" data-value={@option}>
      <span class={"#{@base_class}-option-label"}><%= @option %></span>
    </li>
    """
  end
end
