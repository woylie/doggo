defmodule Doggo.Components.Time do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @precisions [:minute, :second, :millisecond, :microsecond]

  @impl true
  def doc do
    """
    Formats a `Time`, `DateTime`, or `NaiveDateTime` as a time and renders it
    in a `<time>` element.
    """
  end

  @impl true
  def usage(%{name: name, base_class: base_class}) do
    """
    By default, the time part of the given value is formatted for display with
    `to_string/1`. For a `DateTime` or `NaiveDateTime`, the `datetime` attribute
    contains the full value. This:

    ```heex
    <.#{name} value={~T[12:22:06.003]} />
    ```

    Will be rendered as:

    ```html
    <time class="#{base_class}" datetime="12:22:06.003">
      12:22:06.003
    </time>
    ```

    You can also pass a custom formatter function. For example, if you are using
    [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
    application, you could do this:

    ```heex
    <.#{name}
      value={~T[12:22:06.003]}
      formatter={&MyApp.Cldr.Time.to_string!/1}
    />
    ```

    Which, depending on your locale, may be rendered as:

    ```html
    <time class="#{base_class}" datetime="14:22:06.003">
      14:22:06 PM
    </time>
    ```

    The component can also truncate the value before passing it to the
    formatter.

    ```heex
    <.#{name}
      value={~U[2023-02-05 12:22:06.003Z]}
      precision={:minute}
    />
    ```

    If you pass a `title_formatter`, a `title` attribute is added to the
    element. This can be useful if you want to render the value in a shortened
    or relative format, but still give the user access to the complete value.
    Touch devices do not show the `title`.

    ```heex
    <.#{name}
      value={@time}
      formatter={&relative_time/1}
      title_formatter={&MyApp.Cldr.Time.to_string!/1}
    />
    ```

    VoiceOver and Orca do not announce the `datetime` attribute. VoiceOver on
    iOS and Orca do not announce the `title` either. VoiceOver on macOS
    announces an element with a `title` as a group named by the `title`, then
    reads the text and the `title` again. Make sure that the text is
    understandable on its own.

    Finally, the component can shift a `DateTime` to a different time zone:

    ```heex
    <.#{name}
      value={~U[2023-02-05 23:22:05Z]}
      timezone="Asia/Tokyo"
    />
    ```

    Which would be rendered as:

    ```html
    <time class="#{base_class}" datetime="2023-02-06T08:22:05+09:00">
      08:22:05
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
      The API of this component can be considered fairly stable. As measured
      in October 2026, Orca reads ISO 8601 text such as `2023-02-05` as
      separate numbers and dashes and `08:23` as separate numbers and colons.
      VoiceOver reads ISO 8601 dates, but not dates with slashes such as
      `2/5/23`. NVDA, JAWS and TalkBack have not been tested.
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
        Either a `Time`, `DateTime`, or `NaiveDateTime`.
        """

      attr :formatter, :any,
        default: nil,
        doc: """
        A function that takes a `Time`, `DateTime`, or `NaiveDateTime` as an
        argument and returns the value formatted for display. A `DateTime` is
        shifted to `timezone` before it is passed to the formatter.

        Defaults to `to_string/1` on the time part of the value.
        """

      attr :title_formatter, :any,
        default: nil,
        doc: """
        When provided, this function is used to format the time value for the
        `title` attribute. If the attribute is not set, no `title` attribute
        will be added.
        """

      attr :precision, :atom,
        values: unquote(@precisions ++ [nil]),
        default: nil,
        doc: """
        Precision to truncate the given value with. The truncation is applied on
        both the display value and the value of the `datetime` attribute.
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

      attr :localize, :any,
        default: nil,
        doc: unquote(Doggo.localize_doc(:time))

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def template(_opts) do
    quote do
      precision =
        Doggo.time_precision!(var!(assigns), unquote(@precisions), ".time")

      value =
        var!(assigns).value
        |> Doggo.time_value!([Time, DateTime, NaiveDateTime], ".time")
        |> Doggo.shift_zone(var!(assigns).timezone)
        |> Doggo.truncate_datetime(precision)

      var!(assigns) =
        Doggo.assign_time(
          var!(assigns),
          value,
          ".time",
          &(&1 |> Doggo.to_time() |> Doggo.datetime_string(precision)),
          kind: :time
        )

      ~H"""
      <time
        :if={@value}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        datetime={@datetime}
        title={@title}
        {@localize_attrs}
        {@data_attrs}
        {@rest}
      >
        {@value}
      </time>
      """
    end
  end
end
