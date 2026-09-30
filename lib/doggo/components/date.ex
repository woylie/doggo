defmodule Doggo.Components.Date do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @precisions [:year, :month, :month_day, :day]

  @impl true
  def doc do
    """
    Formats a `Date`, `DateTime`, or `NaiveDateTime` as a date and renders it
    in a `<time>` element.
    """
  end

  @impl true
  def usage(%{name: name, base_class: base_class}) do
    """
    By default, the given value is formatted for display in the ISO 8601 format.
    This:

    ```heex
    <.#{name} value={~D[2023-02-05]} />
    ```

    Will be rendered as:

    ```html
    <time class="#{base_class}" datetime="2023-02-05">
      2023-02-05
    </time>
    ```

    You can also pass a custom formatter function. For example, if you are using
    [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
    application, you could do this:

    ```heex
    <.#{name}
      value={~D[2023-02-05]}
      formatter={&MyApp.Cldr.Date.to_string!/1}
    />
    ```

    Which, depending on your locale, may be rendered as:

    ```html
    <time class="#{base_class}" datetime="2023-02-05">
      Feb 2, 2023
    </time>
    ```

    Set `precision` to show fewer units of the date, for example only the year
    of a birthdate. The option is applied to the `datetime` attribute and the
    default formatter. The `formatter` and `title_formatter` functions receive
    the full date.

    ```heex
    <.#{name} value={~D[1980-05-17]} precision={:year} />
    ```

    Which would be rendered as:

    ```html
    <time class="#{base_class}" datetime="1980">
      1980
    </time>
    ```

    If you pass a `title_formatter`, a `title` attribute is added to the
    element. This can be useful if you want to render the value in a shortened
    or relative format, but still give the user access to the complete value.
    Note that the title attribute is only accessible to users who use
    a pointer device. Some screen readers may however announce the `datetime`
    attribute that is always added.

    ```heex
    <.#{name}
      value={@date}
      formatter={&relative_date/1}
      title_formatter={&MyApp.Cldr.Date.to_string!/1}
    />
    ```

    Finally, the component can shift a `DateTime` to a different time zone
    before converting it to a date:

    ```heex
    <.#{name}
      value={~U[2023-02-05 23:22:05Z]}
      timezone="Asia/Tokyo"
    />
    ```

    Which would be rendered as:

    ```html
    <time class="#{base_class}" datetime="2023-02-06">
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
      maturity_note: """
      The API of this component can be considered fairly stable, but there
      are still uncertainties about accessibility aspects, such as the
      handling of the `<time>` element and its `datetime` attribute by screen
      readers and the limited accessibility of the title attribute.
      """,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots(_opts) do
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
        formatted for display. Defaults to the ISO 8601 format, limited to
        `precision`.
        """

      attr :title_formatter, :any,
        default: nil,
        doc: """
        When provided, this function is used to format the date value for the
        `title` attribute. If the attribute is not set, no `title` attribute
        will be added.
        """

      attr :precision, :atom,
        values: unquote(@precisions ++ [nil]),
        default: nil,
        doc: """
        The smallest unit that the `datetime` attribute and the default text
        show. For `1980-05-17`:

        - `:year`: `1980`
        - `:month`: `1980-05`
        - `:month_day`: `05-17`, month and day without the year
        - `:day` or `nil`: `1980-05-17`
        """

      attr :timezone, :string,
        default: nil,
        doc: """
        If set and the given value is a `DateTime`, the value will be shifted to
        that time zone. This affects both the display value and the `datetime`
        attribute. A `NaiveDateTime` is not shifted.

        Note that you need to
        [configure a time zone database](https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database)
        for this to work.

        An unknown time zone raises an error. Validate a time zone taken from
        user input or the browser before you pass it to this component.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def template(_opts) do
    quote do
      precision =
        Doggo.time_precision!(var!(assigns), unquote(@precisions), ".date")

      value =
        var!(assigns).value
        |> Doggo.time_value!([Date, DateTime, NaiveDateTime], ".date")
        |> Doggo.shift_zone(var!(assigns).timezone)
        |> Doggo.to_date()

      var!(assigns) =
        Doggo.assign_time(
          var!(assigns),
          value,
          ".date",
          &Doggo.date_string(&1, precision)
        )

      ~H"""
      <time
        :if={@value}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        datetime={@datetime}
        title={@title}
        {@data_attrs}
        {@rest}
      >
        {@value}
      </time>
      """
    end
  end
end
