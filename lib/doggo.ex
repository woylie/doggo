defmodule Doggo do
  @moduledoc """
  This module only contains miscellaneous functions.

  The components are defined in `Doggo.Components`.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc false
  def slide_label(n), do: "Slide #{n}"

  @doc false
  defmacro diagnostic(do: block) do
    if Application.compile_env(__CALLER__, :doggo, :diagnostics, false) do
      block
    end
  end

  @doc false
  defmacro build(key) do
    case Module.get_attribute(__CALLER__.module, :__dog_render__) do
      %{^key => expression} -> expression
      _ -> __CALLER__.module |> fetch_build!(key) |> Macro.escape()
    end
  end

  attr :content, :any, required: true
  attr :modifiers, :list, required: true
  attr :label, :string, required: true

  @doc false
  def control_content(%{content: nil} = assigns) do
    ~H"<span>{@label}</span>"
  end

  def control_content(assigns) do
    ~H"{@content.(Map.new(@modifiers))}"
  end

  @doc false
  defmacro build(key, suffix) do
    "#{fetch_build!(__CALLER__.module, key)}#{suffix}"
  end

  defp fetch_build!(module, key) do
    module
    |> Module.get_attribute(:__dog_build__)
    |> Doggo.Template.fetch!(key)
  end

  @doc false
  def capture_name(fun) do
    {:module, module} = Function.info(fun, :module)
    {:name, name} = Function.info(fun, :name)
    {module, name}
  end

  @doc false
  def assign_derived(%{__changed__: changed} = assigns, derived, inputs)
      when is_map(changed) do
    if Enum.any?(inputs, &Map.has_key?(changed, &1)) do
      assign(assigns, derived)
    else
      Enum.into(derived, assigns)
    end
  end

  def assign_derived(assigns, derived, _inputs), do: assign(assigns, derived)

  @doc false
  def attr_default(assigns, name, fun) do
    if Map.has_key?(assigns, name),
      do: assigns,
      else: Map.put(assigns, name, fun.())
  end

  @doc false
  def slot_default(
        %{data_attrs: %{data: modifiers}} = assigns,
        name,
        fun,
        attrs
      ) do
    case assigns do
      %{^name => []} ->
        entry =
          Map.merge(attrs.(), %{
            __slot__: name,
            inner_block: fn _changed, _arg -> fun.(Map.new(modifiers)) end
          })

        assign_derived(assigns, [{name, [entry]}], Keyword.keys(modifiers))

      _ ->
        assigns
    end
  end

  @doc false
  def assign_time(assigns, value, component, default_formatter, opts) do
    formatter = time_formatter!(assigns.formatter, :formatter, component)

    title_formatter =
      assigns
      |> Map.get(:title_formatter)
      |> time_formatter!(:title_formatter, component)

    localize =
      localize!(assigns.localize, Keyword.fetch!(opts, :kind), component)

    title_formatter = title_formatter || pattern_formatter(localize[:title])

    datetime = Keyword.get(opts, :datetime, value)

    default_formatter =
      pattern_formatter(localize[:pattern]) || default_formatter

    assign_derived(
      assigns,
      [
        datetime:
          datetime && datetime_attr(datetime, Map.get(assigns, :precision)),
        title: value && title_formatter && title_formatter.(value),
        value: value && (formatter || default_formatter).(value),
        localize_attrs: localize_attrs(localize, assigns)
      ],
      [
        :value,
        :precision,
        :timezone,
        :formatter,
        :title_formatter,
        :localize
      ]
    )
  end

  defp time_formatter!(fun, _attr, _component)
       when is_nil(fun) or is_function(fun, 1),
       do: fun

  defp time_formatter!(value, attr, component) do
    raise ArgumentError, """
    invalid #{attr} value for #{component}

    #{attr} must be a function that takes one argument.

    Got:

        #{inspect(value)}
    """
  end

  @localize_styles [:short, :medium, :long, :full]
  @localize_zones [:viewer, :server]
  @localize_parts [
    :weekday,
    :era,
    :year,
    :month,
    :day,
    :day_period,
    :hour,
    :minute,
    :second,
    :fractional_second_digits,
    :time_zone_name,
    :hour_cycle,
    :hour12
  ]
  @localize_clock [:hour_cycle, :hour12]
  @localize_directives %{
    date: ~c"Yymd%",
    time: ~c"HIMSpz%",
    datetime: ~c"YymdHIMSpz%"
  }

  @localize_examples %{
    date: "%Y-%m-%d",
    time: "%H:%M",
    datetime: "%Y-%m-%d %H:%M"
  }

  @doc false
  def localize_doc(kind) do
    example = Map.fetch!(@localize_examples, kind)

    directives =
      @localize_directives
      |> Map.fetch!(kind)
      |> Enum.map_join(" ", &"`%#{<<&1>>}`")

    """
    Formats the text in the browser, in the page's language and the user's
    time zone. The server's text is shown until the script runs, and if no
    JavaScript is available.

    - `true`: the locale's default format.
    - A style, `:short`, `:medium`, `:long` or `:full`, which the locale
      arranges.
    - A `strftime` pattern, such as `"#{example}"`, for a fixed format. It
      can only use the directives #{directives}. Without a `formatter`, the
      server renders the same pattern with `Calendar.strftime/2`.
    - A keyword list with `:style`, `:pattern` or `Intl.DateTimeFormat`
      options, such as `[weekday: :short, month: :long, day: :numeric]`, and
      `:zone`.

    `:zone` is the time zone the browser formats in:

    - `:viewer`: the user's time zone (default)
    - `:server`: the time zone the server rendered the value in. Use if
      `timezone` is a zone that the user chose.
    - a time zone name.

    `:title` sets the format of the `title` attribute, as a style or a
    pattern, for example `title: :full`. The browser formats the `title` in
    the same language and time zone as the text. Without `:title`, the title
    value as rendered by the server using `title_formatter` remains visible.
    If you pass a pattern and no `title_formatter`, the server also uses the
    pattern for the `title`.

    The language is the page's `lang`. If it names only a language, such as
    `en`, and the browser's language is the same, the browser's own locale
    decides the regional conventions. Browsers do not pass on a clock set in
    the operating system, so pass the user's stored choice as `hour_cycle:
    :h23` or `hour_cycle: :h12`.

    Call `localizeTimes()` from `@woylie/doggo` in your `app.js` before
    connecting the LiveSocket. Elements with this attribute have
    `translate="no"`, so that translation tools do not change their text.
    """
  end

  @doc false
  def localize!(value, kind, component)
  def localize!(nil, _kind, _component), do: nil
  def localize!(false, _kind, _component), do: nil
  def localize!(true, kind, component), do: localize!([], kind, component)

  def localize!(pattern, kind, component) when is_binary(pattern) do
    localize!([pattern: pattern], kind, component)
  end

  def localize!(style, kind, component) when is_atom(style) do
    localize!([style: style], kind, component)
  end

  def localize!(opts, kind, component) when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, localize_message(opts, component)
    end

    {style, rest} = Keyword.pop(opts, :style)
    {pattern, rest} = Keyword.pop(rest, :pattern)
    {zone, rest} = Keyword.pop(rest, :zone, :viewer)
    {title, rest} = Keyword.pop(rest, :title)
    {parts, unknown} = Keyword.split(rest, @localize_parts)

    valid? =
      unknown == [] and
        valid_localize?(style, pattern, zone, title, parts)

    if not valid? do
      raise ArgumentError, localize_message(opts, component)
    end

    for pattern <- [pattern, title], is_binary(pattern) do
      ensure_directives!(pattern, kind, component)
    end

    %{
      kind: kind,
      style: style,
      pattern: pattern,
      zone: zone,
      title: title,
      parts: parts
    }
  end

  def localize!(value, _kind, component) do
    raise ArgumentError, localize_message(value, component)
  end

  defp valid_localize?(style, pattern, zone, title, parts) do
    shapes =
      Enum.count(
        [style, pattern, Keyword.drop(parts, @localize_clock) != [] || nil],
        & &1
      )

    shapes <= 1 and localize_style?(style) and localize_pattern?(pattern) and
      localize_zone?(zone) and localize_title?(title)
  end

  defp localize_style?(style), do: is_nil(style) or style in @localize_styles
  defp localize_pattern?(pattern), do: is_nil(pattern) or is_binary(pattern)
  defp localize_zone?(zone), do: zone in @localize_zones or is_binary(zone)

  defp localize_title?(title) do
    is_nil(title) or title in @localize_styles or is_binary(title)
  end

  defp ensure_directives!(pattern, kind, component) do
    allowed = Map.fetch!(@localize_directives, kind)

    invalid =
      for [directive] <- Regex.scan(~r/%(.?)/, pattern, capture: :all_but_first),
          directive == "" or String.to_charlist(directive) -- allowed != [] do
        directive
      end

    if invalid != [] do
      raise ArgumentError, """
      invalid localize pattern for #{component}

      The pattern can only use these directives:

          #{Enum.map_join(allowed, " ", &"%#{<<&1>>}")}

      Got:

          #{inspect(pattern)}
      """
    end
  end

  defp localize_message(value, component) do
    """
    invalid localize value for #{component}

    localize takes true, a style (:short, :medium, :long, :full), a strftime
    pattern, or a keyword list with :style, :pattern or Intl.DateTimeFormat
    options, :zone (:viewer, :server or a time zone name), and :title (a
    style or a pattern for the title). A pattern cannot be combined with a
    style or options, nor a style with options.

    Got:

        #{inspect(value)}
    """
  end

  defp localize_attrs(nil, _assigns), do: %{}

  defp localize_attrs(localize, assigns) do
    [
      {"data-localize", localize.kind},
      {"data-localize-style", localize.style},
      {"data-localize-pattern", localize.pattern},
      {"data-localize-zone", localize.zone != :viewer && localize.zone},
      {"data-localize-title", localize.title},
      {"data-timezone", assigns.timezone},
      {"translate", "no"}
      | Enum.map(localize.parts, fn {key, value} ->
          {"data-localize-#{String.replace(to_string(key), "_", "-")}", value}
        end)
    ]
    |> Enum.reject(fn {_key, value} -> value in [nil, false] end)
    |> Map.new(fn {key, value} -> {key, to_string(value)} end)
  end

  defp pattern_formatter(pattern) when is_binary(pattern) do
    &Calendar.strftime(&1, pattern)
  end

  defp pattern_formatter(_), do: nil

  @doc false
  def time_value!(nil, _structs, _component), do: nil

  def time_value!(value, structs, component) do
    if is_struct(value) and value.__struct__ in structs do
      value
    else
      raise ArgumentError, expected_message(:value, component, structs, value)
    end
  end

  @doc false
  def time_precision!(%{precision: precision}, values, component) do
    if is_nil(precision) or precision in values do
      precision
    else
      raise ArgumentError,
            expected_message(:precision, component, values, precision)
    end
  end

  defp expected_message(attr, component, expected, value) do
    """
    invalid #{attr} for #{component}

    Expected one of:

    #{Enum.map_join(expected, "\n", &"    #{inspect(&1)}")}

    Got:

        #{inspect(value)}
    #{time_value_hint(value)}
    """
  end

  defp time_value_hint(%Date{}), do: "\nUse .date for a Date."
  defp time_value_hint(%Time{}), do: "\nUse .time for a Time."

  defp time_value_hint(%NaiveDateTime{}) do
    "\nUse DateTime.from_naive!/2 to give a NaiveDateTime a time zone."
  end

  defp time_value_hint(_), do: ""

  @doc false
  def to_js!(value, attr, component) do
    case callback!(value, attr, component) do
      event when is_binary(event) -> JS.push(event)
      js -> js
    end
  end

  @doc false
  def callback!(%JS{} = js, _attr, _component), do: js
  def callback!(event, _attr, _component) when is_binary(event), do: event
  def callback!(nil, _attr, _component), do: nil

  def callback!(value, attr, component) do
    raise ArgumentError, """
    invalid #{attr} value for #{component}

    #{attr} must be a Phoenix.LiveView.JS command or an event name as a string.

    Got:

        #{inspect(value)}
    """
  end

  @doc false
  def truncate_datetime(nil, _), do: nil
  def truncate_datetime(v, nil), do: v
  def truncate_datetime(v, :minute), do: %{v | second: 0, microsecond: {0, 0}}

  def truncate_datetime(%DateTime{} = dt, precision) do
    DateTime.truncate(dt, precision)
  end

  def truncate_datetime(%NaiveDateTime{} = dt, precision) do
    NaiveDateTime.truncate(dt, precision)
  end

  def truncate_datetime(%Time{} = t, precision) do
    Time.truncate(t, precision)
  end

  @doc false
  def shift_zone(%DateTime{} = dt, tz) when is_binary(tz) do
    DateTime.shift_zone!(dt, tz)
  end

  def shift_zone(v, _), do: v

  @doc false
  def datetime_attr(%Date{} = date, precision) do
    date = Date.convert!(date, Calendar.ISO)

    if date.year > 0 or precision == :month_day do
      date_string(date, precision)
    end
  end

  def datetime_attr(%Time{} = time, precision) do
    time
    |> Time.convert!(Calendar.ISO)
    |> Time.truncate(:millisecond)
    |> Time.to_iso8601()
    |> drop_seconds(precision)
  end

  # An offset with seconds, such as +09:18:59 in Tokyo before 1888, is written
  # in UTC, because the HTML format has no seconds in offsets.
  def datetime_attr(%DateTime{utc_offset: utc, std_offset: std} = dt, precision)
      when rem(utc + std, 60) != 0 do
    dt |> DateTime.shift_zone!("Etc/UTC") |> datetime_attr(precision)
  end

  def datetime_attr(%struct{} = value, precision)
      when struct in [DateTime, NaiveDateTime] do
    value =
      value
      |> struct.convert!(Calendar.ISO)
      |> struct.truncate(:millisecond)

    if value.year > 0 do
      value |> struct.to_iso8601() |> drop_seconds(precision)
    end
  end

  @doc false
  def date_string(date, precision) do
    iso = Date.to_iso8601(date)

    case precision do
      :year -> String.slice(iso, 0..-7//1)
      :month -> String.slice(iso, 0..-4//1)
      :month_day -> String.slice(iso, -5..-1//1)
      _ -> iso
    end
  end

  @doc false
  def datetime_string(value, precision) do
    value |> to_string() |> drop_seconds(precision)
  end

  defp drop_seconds(iso, :minute) do
    String.replace(iso, ~r/(\d\d:\d\d):00/, "\\1", global: false)
  end

  defp drop_seconds(iso, _), do: iso

  @doc false
  def to_date(%Date{} = d), do: d
  def to_date(%DateTime{} = dt), do: DateTime.to_date(dt)
  def to_date(%NaiveDateTime{} = dt), do: NaiveDateTime.to_date(dt)
  def to_date(nil), do: nil

  @doc false
  def to_time(%Time{} = t), do: t
  def to_time(%DateTime{} = dt), do: DateTime.to_time(dt)
  def to_time(%NaiveDateTime{} = dt), do: NaiveDateTime.to_time(dt)
  def to_time(nil), do: nil

  ## JS functions

  @doc """
  Hides the modal with the given ID.

  The component needs its JavaScript hook registered, since this function uses
  the hook to call `close()` on the dialog.

  ## Example

  ```heex
  <.link phx-click={hide_modal("pet-modal")}>hide</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"
  @spec hide_modal(JS.t(), String.t()) :: JS.t()
  def hide_modal(js \\ %JS{}, id) when is_binary(id) do
    JS.dispatch(js, "doggo:close", to: id_selector(id))
  end

  @doc """
  Shows the modal with the given ID.

  The component needs its JavaScript hook registered, since this function uses
  the hook to call `showModal()` on the dialog.

  ## Example

  ```heex
  <.link phx-click={show_modal("pet-modal")}>show</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"
  @spec show_modal(JS.t(), String.t()) :: JS.t()
  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    JS.dispatch(js, "doggo:open", to: id_selector(id))
  end

  @doc """
  Shows the tab with the given index of the `tabs/1` component with the given
  ID.

  The index is one-based. The component needs its JavaScript hook registered,
  since this function uses the hook to select the tab.

  ## Example

      Doggo.show_tab("my-tabs", 2)
  """
  @doc type: :js
  @doc since: "0.5.0"
  @spec show_tab(JS.t(), String.t(), integer()) :: JS.t()
  def show_tab(js \\ %JS{}, id, index)
      when is_binary(id) and is_integer(index) do
    JS.dispatch(js, "doggo:show-tab",
      to: id_selector(id),
      detail: %{index: index}
    )
  end

  @doc false
  def dialog_mounted(id, open) when is_binary(id) and is_boolean(open) do
    js = JS.ignore_attributes(["open"])

    if open, do: show_modal(js, id), else: js
  end

  @doc false
  def toggle_accordion_section(id, index)
      when is_binary(id) and is_integer(index) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"},
      to: id_selector("#{id}-trigger-#{index}")
    )
    |> JS.toggle_attribute({"hidden", ""},
      to: id_selector("#{id}-section-#{index}")
    )
  end

  @doc false
  def toggle_disclosure(target_id) when is_binary(target_id) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"})
    |> JS.toggle_attribute({"hidden", ""}, to: id_selector(target_id))
  end

  @doc false
  def id_selector(id), do: "#" <> css_escape(id)

  defp css_escape("-"), do: "\\-"
  defp css_escape("-" <> rest), do: "-" <> escape_start(rest)
  defp css_escape(id), do: escape_start(id)

  defp escape_start(<<c, rest::binary>>) when c in ?0..?9 do
    hex_escape(c) <> escape_rest(rest)
  end

  defp escape_start(id), do: escape_rest(id)

  defp escape_rest(id) do
    Regex.replace(
      ~r/[\x{1}-\x{1f}\x{7f}]|[^\x{80}-\x{10ffff}A-Za-z0-9_-]/u,
      id,
      fn
        <<c::utf8>> when c < 0x20 or c == 0x7F -> hex_escape(c)
        char -> "\\" <> char
      end
    )
  end

  defp hex_escape(c) do
    "\\" <> String.downcase(Integer.to_string(c, 16)) <> " "
  end

  ## Modifier classes

  @doc """
  Returns all component classes and data attributes used in the given components
  module.

  This includes the base classes, nested classes (based on the base class)
  and modifier classes.

  ## Usage

      safelist(MyAppWeb.CoreComponents)
      #=> ["button", "data-size", "data-variant"]
  """
  @doc since: "0.13.0"
  @spec safelist(module) :: [String.t()]
  def safelist(module) when is_atom(module) do
    components = module.__dog_components__()
    base_classes = Enum.map(components, &get_base_class/1)
    data_attrs = Enum.flat_map(components, &data_attrs/1)
    modifier_data_attrs = Enum.flat_map(components, &modifier_data_attrs/1)
    nested_classes = Enum.flat_map(components, &get_nested_classes/1)

    (base_classes ++ data_attrs ++ modifier_data_attrs ++ nested_classes)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp get_base_class({_, info}) do
    Keyword.get(info, :base_class)
  end

  defp data_attrs({_, info}) do
    Keyword.get(info, :data_attrs, [])
  end

  defp modifier_data_attrs({_, info}) do
    info
    |> Keyword.fetch!(:modifiers)
    |> Enum.map(fn {name, _} -> "data-#{name}" end)
  end

  defp get_nested_classes({_, info}) do
    base_class = Keyword.get(info, :base_class)
    component_module = info |> Keyword.fetch!(:component) |> component_module()
    component_module.nested_classes(base_class)
  end

  defp component_module(name) when is_atom(name) do
    module_name = name |> Atom.to_string() |> Macro.camelize()
    Module.safe_concat([Doggo.Components, module_name])
  end

  @doc false
  def ensure_own_attributes!(assigns, own_attributes, component) do
    rest = Map.get(assigns, :rest, %{})

    for {name, instead} <- own_attributes, Map.has_key?(rest, name) do
      raise ArgumentError, """
      #{name} is set by #{component}

      The component renders its own #{name} attribute. An attribute value passed
      directly is ignored by the browser.#{use_instead(instead)}

      Got:

          #{name}=#{inspect(rest[name])}
      """
    end

    :ok
  end

  defp use_instead(nil), do: ""
  defp use_instead(attr), do: " Use the #{attr} attribute instead."

  @doc false
  def ensure_label!(
        %{label: label, labelledby: labelledby},
        component,
        example_label
      ) do
    if named?(label) != named?(labelledby) do
      :ok
    else
      raise Doggo.InvalidLabelError,
        component: component,
        example_label: example_label
    end
  end

  @doc false
  def ensure_name!(name, component, attr) do
    if named?(name) do
      :ok
    else
      raise ArgumentError, """
      blank #{attr} for #{component}

      The #{attr} is the accessible name. Set it to a text that describes the
      element, and make sure that it is translated.

          #{attr}: #{inspect(name)}
      """
    end
  end

  @doc false
  def class_attr(nil), do: []
  def class_attr(class), do: [class: class]

  @doc false
  def ensure_optional_name!(nil, _component, _attr), do: :ok

  def ensure_optional_name!(name, component, attr) do
    ensure_name!(name, component, attr)
  end

  @doc false
  def named?(s) when is_binary(s), do: String.trim(s) != ""
  def named?(nil), do: false
  def named?(_), do: true
end
