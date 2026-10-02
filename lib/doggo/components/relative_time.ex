defmodule Doggo.Components.RelativeTime do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @formats [:long, :short, :narrow]
  @numerics [:auto, :always]
  @tenses [:auto, :past, :future]

  @impl true
  def doc do
    """
    Renders a `DateTime` or `Date` relative to now, such as "3 minutes ago" or
    "yesterday", in a `<time>` element.
    """
  end

  @impl true
  def usage(%{name: name}) do
    """
    The server renders the absolute value. The browser replaces it with the
    relative text in the page's language, which requires calling
    `relativeTimes()` from `@woylie/doggo` in your `app.js`. Without
    JavaScript, the absolute value remains.

    ```heex
    <.#{name} value={@post.inserted_at} />
    ```

    The text is converted once. Set `sync` to keep it up to date while the
    page is open:

    ```heex
    <.#{name} value={@message.sent_at} sync />
    ```

    Past a `threshold`, the absolute value is shown instead. With `localize`,
    the absolute value is in the user's format:

    ```heex
    <.#{name}
      value={@event.starts_at}
      threshold={Duration.new!(week: 1)}
      localize={:medium}
    />
    ```

    The `title` contains the absolute value.

    A `Date` is compared by calendar day, so the text reads "yesterday" or
    "in 2 days".

    To stop the relative times inside an element from updating, for example as
    a user setting, set `data-relative-sync="false"` on that element. It
    overrides `sync`.

    VoiceOver on macOS announces the element as a group named by the `title`,
    then reads the text and the `title` again. Without JavaScript, past the
    threshold and when printing, the text is the absolute value. Orca reads
    the default ISO 8601 text as separate numbers and dashes. VoiceOver reads
    it as a date, but not a date with slashes such as `2/5/23`, which
    `localize={:short}` writes in some locales. To write the month as a word,
    set `localize` to `:long`, or pass a `formatter` that uses the locale data
    of your application. Only a
    `formatter` changes the text for users without JavaScript.
    """
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.18.0",
      maturity: :developing,
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
        A `DateTime` or a `Date`.
        """

      attr :formatter, :any,
        default: nil,
        doc: """
        A function that formats the absolute value on the server. Defaults to
        `to_string/1`.

        The absolute value is the text without JavaScript and before the
        script runs. The browser also shows it past the `threshold` and when
        printing, unless `localize` is set, and in the `title`, unless
        `localize` has `:title`.
        """

      attr :timezone, :string,
        default: nil,
        doc: """
        The time zone of the absolute value the server renders.
        """

      attr :format, :atom,
        values: unquote(@formats),
        default: :long,
        doc: """
        The length of the relative text: `:long` ("3 minutes ago"), `:short`
        ("3 min. ago") or `:narrow` ("3m ago"). Some locales use the same text
        for more than one.
        """

      attr :numeric, :atom,
        values: unquote(@numerics),
        default: :auto,
        doc: """
        With `:auto`, the text can be "yesterday"; with `:always`, it is
        "1 day ago". Under a minute, both write "now".
        """

      attr :sync, :boolean,
        default: false,
        doc: """
        Keeps the text up to date while the page is open. Without it, the text
        is converted once.
        """

      attr :threshold, :any,
        default: nil,
        doc: """
        A `Duration` without months or years, or a number of seconds. Past it,
        the absolute value is shown instead of the relative text.
        """

      attr :tense, :atom,
        values: unquote(@tenses),
        default: :auto,
        doc: """
        With `:past`, a value slightly in the future reads "now"; with
        `:future`, a value slightly in the past does. Useful when the clocks
        of the server and the browser differ.
        """

      attr :now, :any,
        default: nil,
        doc: """
        The server's current time as a `DateTime`. The browser corrects its
        own clock by the difference when it first sees the element. Leave it
        unset for a page that is cached, since the time would be stale.
        """

      attr :localize, :any,
        default: nil,
        doc: """
        The format of the absolute value in the browser, past the `threshold`
        and in the `title`. Takes the same values as for `datetime`.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def template(_opts) do
    quote do
      value =
        Doggo.time_value!(
          var!(assigns).value,
          [DateTime, Date],
          ".relative_time"
        )

      shifted = Doggo.shift_zone(value, var!(assigns).timezone)

      relative_attrs = unquote(__MODULE__).relative_attrs(var!(assigns))

      var!(assigns) =
        Doggo.assign_time(
          var!(assigns),
          shifted,
          ".relative_time",
          &to_string/1,
          kind: if(is_struct(value, Date), do: :date, else: :datetime),
          datetime: unquote(__MODULE__).instant(value)
        )

      var!(assigns) =
        Doggo.assign_derived(
          var!(assigns),
          [relative_attrs: relative_attrs],
          [:value, :format, :numeric, :sync, :threshold, :tense, :now]
        )

      ~H"""
      <time
        :if={@value}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        datetime={@datetime}
        dir="auto"
        {Map.merge(@localize_attrs, @relative_attrs)}
        {@data_attrs}
        {@rest}
      >
        {@value}
      </time>
      """
    end
  end

  @doc false
  def instant(%DateTime{} = value), do: DateTime.shift_zone!(value, "Etc/UTC")
  def instant(value), do: value

  @doc false
  def relative_attrs(%{value: nil}), do: %{}

  def relative_attrs(assigns) do
    kind = if is_struct(assigns.value, Date), do: "date", else: "datetime"

    [
      {"data-relative", kind},
      {"translate", "no"},
      {"data-relative-format", assigns.format != :long && assigns.format},
      {"data-relative-numeric", assigns.numeric != :auto && assigns.numeric},
      {"data-relative-sync", assigns.sync && "true"},
      {"data-relative-tense", assigns.tense != :auto && assigns.tense},
      {"data-relative-threshold", threshold!(assigns.threshold)},
      {"data-relative-now", now!(assigns.now)}
    ]
    |> Enum.reject(fn {_key, value} -> value in [nil, false] end)
    |> Map.new(fn {key, value} -> {key, to_string(value)} end)
  end

  defp threshold!(nil), do: nil

  defp threshold!(seconds) when is_integer(seconds) and seconds >= 0 do
    seconds
  end

  defp threshold!(%Duration{month: 0, year: 0} = duration)
       when duration.week >= 0 and duration.day >= 0 and duration.hour >= 0 and
              duration.minute >= 0 and duration.second >= 0 do
    div(to_timeout(duration), 1000)
  end

  defp threshold!(value) do
    raise ArgumentError, """
    invalid threshold value for .relative_time

    threshold must be a Duration without months or years, or a number of
    seconds.

    Got:

        #{inspect(value)}
    """
  end

  defp now!(nil), do: nil

  defp now!(%DateTime{} = now), do: now |> instant() |> Doggo.datetime_attr(nil)

  defp now!(value) do
    raise ArgumentError, """
    invalid now value for .relative_time

    now must be a DateTime.

    Got:

        #{inspect(value)}
    """
  end
end
