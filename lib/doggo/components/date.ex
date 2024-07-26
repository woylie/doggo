defmodule Doggo.Components.Date do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Formats a `Date`, `DateTime`, or `NaiveDateTime` as a date and renders it
    in a `<time>` element.
    """
  end

  @impl true
  def usage do
    """
    By default, the given value is formatted for display with `to_string/1`. This:

    ```heex
    <.date value={~D[2023-02-05]} />
    ```

    Will be rendered as:

    ```html
    <time datetime="2023-02-05">
      2023-02-05
    </time>
    ```

    You can also pass a custom formatter function. For example, if you are using
    [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
    application, you could do this:

    ```heex
    <.date
      value={~D[2023-02-05]}
      formatter={&MyApp.Cldr.Date.to_string!/1}
    />
    ```

    Which, depending on your locale, may be rendered as:

    ```html
    <time datetime="2023-02-05">
      Feb 2, 2023
    </time>
    ```

    If you pass a `title_formatter`, a `title` attribute is added to the
    element. This can be useful if you want to render the value in a shortened
    or relative format, but still give the user access to the complete value.
    Note that the title attribute is only be accessible to users who use
    a pointer device. Some screen readers may however announce the `datetime`
    attribute that is always added.

    ```heex
    <.date
      value={@date}
      formatter={relative_date(@date)}
      title_formatter={&MyApp.Cldr.Date.to_string!/1}
    />
    ```

    Finally, the component can shift a `DateTime` to a different time zone
    before converting it to a date:

    ```heex
    <.date
      value={~U[2023-02-05 23:22:05Z]}
      timezone="Asia/Tokyo"
    />
    ```

    Which would be rendered as:

    ```html
    <time datetime="2023-02-06">
      2023-02-06
    </time>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :refining,
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
        Either a `Date`, `DateTime`, or `NaiveDateTime`.
        """

      attr :formatter, :any,
        default: nil,
        doc: """
        A function that takes a `Date` as an argument and returns the value
        formatted for display. Defaults to `to_string/1`.
        """

      attr :title_formatter, :any,
        default: nil,
        doc: """
        When provided, this function is used to format the date value for the
        `title` attribute. If the attribute is not set, no `title` attribute will
        be added.
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

      attr :rest, :global, include: ~w(autofocus form name value)
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
          timezone: timezone,
          formatter: formatter,
          title_formatter: title_formatter
        } = assigns
      ) do
    formatter = formatter || (&to_string/1)

    value =
      value
      |> Doggo.shift_zone(timezone)
      |> Doggo.to_date()

    assigns =
      assigns
      |> assign(:datetime, value && Date.to_iso8601(value))
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
