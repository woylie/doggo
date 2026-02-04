defmodule Doggo.Components.RadioGroup do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a group of radio buttons, for example for a toolbar.

    To render radio buttons within a regular form, use `input/1` with the
    `"radio-group"` type instead.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.radio_group
      id="favorite-dog"
      name="favorite-dog"
      label="Favorite Dog"
      options={[
        {"Labrador Retriever", "labrador"},
        {"German Shepherd", "german_shepherd"},
        {"Golden Retriever", "golden_retriever"},
        {"French Bulldog", "french_bulldog"},
        {"Beagle", "beagle"}
      ]}
    />
    ```

    ## CSS

    To target the wrapper, you can use an attribute selector:

    ```css
    [role="radio-group"] {}
    ```
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
      since: "0.6.0",
      maturity: :experimental,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :name, :string,
        required: true,
        doc: "The `name` attribute for the `input` elements."

      attr :label, :string,
        default: nil,
        doc: """
        A accessibility label for the radio group. Set as `aria-label` attribute.

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels this radio group.

        Example:

        ```html
        <h3 id="dog-rg-label">Favorite Dog</h3>
        <.radio_group labelledby="dog-rg-label"></.radio_group>
        ```

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :options, :list,
        required: true,
        doc: """
        A list of options. It can be given a list values or as a list of
        `{label, value}` tuples.
        """

      attr :value, :any,
        default: nil,
        doc: """
        The currently selected value, which is compared with the option value to
        determine whether a radio button is checked.
        """

      attr :required, :boolean, default: false

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    Doggo.ensure_label!(assigns, ".radio_group", "Favorite Dog")

    ~H"""
    <div
      id={@id}
      role="radiogroup"
      aria-label={@label}
      aria-labelledby={@labelledby}
      class={@class}
      {@data_attrs}
      {@rest}
    >
      <.radio
        :for={option <- @options}
        option={option}
        name={@name}
        id={@id}
        value={@value}
        errors={[]}
        description={[]}
        required={@required}
      />
    </div>
    """
  end

  @doc false
  def radio(
        %{option_value: _, id: id, description: description, errors: errors} =
          assigns
      ) do
    assigns =
      assign(assigns,
        describedby: Doggo.input_aria_describedby(id, description),
        errormessage: Doggo.input_aria_errormessage(id, errors),
        invalid: errors != [] && "true"
      )

    ~H"""
    <label>
      <input
        type="radio"
        name={@name}
        id={@id <> "_#{@option_value}"}
        value={@option_value}
        checked={Doggo.checked?(@option_value, @value)}
        aria-describedby={@describedby}
        aria-errormessage={@errormessage}
        aria-invalid={@invalid}
        required={@required}
      />
      {@label}
    </label>
    """
  end

  def radio(%{option: {option_label, option_value}} = assigns) do
    assigns
    |> assign(label: option_label, option_value: option_value, option: nil)
    |> radio()
  end

  def radio(%{option: option_value} = assigns) do
    assigns
    |> assign(
      label: Doggo.humanize(option_value),
      option_value: option_value,
      option: nil
    )
    |> radio()
  end
end
