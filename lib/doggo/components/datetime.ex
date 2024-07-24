defmodule Doggo.Components.Datetime do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a `DateTime` or `NaiveDateTime` in a `<time>` tag.
    """
  end

  @impl true
  def usage do
    """
    By default, the given value is formatted for display with `to_string/1`. This:

    ```heex
    <.datetime value={~U[2023-02-05 12:22:06.003Z]} />
    ```

    Will be rendered as:

    ```html
    <time datetime="2023-02-05T12:22:06.003Z">
      2023-02-05 12:22:06.003Z
    </time>
    ```

    You can also pass a custom formatter function. For example, if you are using
    [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
    application, you could do this:

    ```heex
    <.datetime
      value={~U[2023-02-05 14:22:06.003Z]}
      formatter={&MyApp.Cldr.DateTime.to_string!/1}
    />
    ```

    Which, depending on your locale, may be rendered as:

    ```html
    <time datetime="2023-02-05T14:22:06.003Z">
      Feb 2, 2023, 14:22:06 PM
    </time>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :developing,
      base_class: nil,
      modifiers: []
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :value, :any,
        required: true,
        doc: """
        Either a `DateTime` or `NaiveDateTime`.
        """

      attr :formatter, :any,
        default: nil,
        doc: """
        A function that takes a `DateTime` or a `NaiveDateTime` as an argument and
        returns the value formatted for display. Defaults to `to_string/1`.
        """

      attr :title_formatter, :any,
        default: nil,
        doc: """
        When provided, this function is used to format the date time value for the
        `title` attribute. If the attribute is not set, no `title` attribute will
        be added.
        """

      attr :precision, :atom,
        values: [:minute, :second, :millisecond, :microsecond, nil],
        default: nil,
        doc: """
        Precision to truncate the given value with. The truncation is applied on
        both the display value and the value of the `datetime` attribute.
        """

      attr :timezone, :string,
        default: nil,
        doc: """
        If set and the given value is a `DateTime`, the value will be shifted to
        that time zone. This affects both the display value and the `datetime` tag.
        Note that you need to
        [configure a time zone database](https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database)
        for this to work.
        """

      attr :rest, :global
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(
        %{
          value: value,
          precision: precision,
          timezone: timezone,
          formatter: formatter,
          title_formatter: title_formatter
        } = assigns
      ) do
    formatter = formatter || (&to_string/1)

    value =
      value
      |> Doggo.shift_zone(timezone)
      |> Doggo.truncate_datetime(precision)

    assigns =
      assigns
      |> assign(:datetime, value && Doggo.datetime_attr(value))
      |> assign(
        :title,
        value && Doggo.time_title_attr(value, title_formatter)
      )
      |> assign(:value, value && formatter.(value))

    ~H"""
    <time :if={@value} class={@class} datetime={@datetime} title={@title} {@rest}>
      <%= @value %>
    </time>
    """
  end
end
