defmodule Doggo do
  @moduledoc """
  This module only contains miscellaneous functions.

  The components are defined in `Doggo.Components`.
  """

  use Phoenix.Component

  alias Phoenix.HTML.Form
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
    __CALLER__.module |> fetch_build!(key) |> Macro.escape()
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
  def assign_time(assigns, value, to_iso) do
    assign_derived(
      assigns,
      [
        datetime: value && to_iso.(value),
        title: value && time_title_attr(value, assigns.title_formatter),
        value: value && (assigns.formatter || (&to_string/1)).(value)
      ],
      [:value, :precision, :timezone, :formatter, :title_formatter]
    )
  end

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
  def datetime_attr(%DateTime{} = dt) do
    DateTime.to_iso8601(dt)
  end

  def datetime_attr(%NaiveDateTime{} = dt) do
    NaiveDateTime.to_iso8601(dt)
  end

  # don't add title attribute if no title formatter is set
  @doc false
  def time_title_attr(_, nil), do: nil
  def time_title_attr(v, fun) when is_function(fun, 1), do: fun.(v)

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

  @doc false
  def normalize_value("date", %struct{} = value)
      when struct in [Date, NaiveDateTime, DateTime] do
    value |> to_date() |> Date.to_iso8601()
  end

  def normalize_value("date", <<date::10-binary, _::binary>>) do
    case Date.from_iso8601(date) do
      {:ok, _} -> date
      {:error, _} -> ""
    end
  end

  def normalize_value("date", _), do: ""
  def normalize_value(type, value), do: Form.normalize_value(type, value)

  # The error id is added to both `aria-describedby` and `aria-errormessage`,
  # because `aria-errormessage` support is patchy. The order matches the DOM.
  @doc false
  def input_aria_describedby(_id, [], []), do: nil
  def input_aria_describedby(id, [], _errors), do: field_errors_id(id)
  def input_aria_describedby(id, _description, []), do: field_description_id(id)

  def input_aria_describedby(id, _description, _errors),
    do: "#{field_errors_id(id)} #{field_description_id(id)}"

  @doc false
  def option_from_keyword(option) do
    {key, option} = Keyword.pop(option, :key)

    key ||
      raise ArgumentError,
            "expected :key key when building an option from a keyword list: #{inspect(option)}"

    {value, option} = Keyword.pop(option, :value)

    value ||
      raise ArgumentError,
            "expected :value key when building an option from a keyword list: #{inspect(option)}"

    {description, extra} = Keyword.pop(option, :description)
    {key, value, description, extra}
  end

  @doc false
  def describe_option(assigns) do
    description = Map.get(assigns, :option_description)

    id =
      if description do
        "#{assigns.id}_#{id_fragment(assigns.option_value)}_description"
      end

    Map.merge(assigns, %{
      option_description: description,
      option_description_id: id,
      describedby: join_ids([assigns.describedby, id])
    })
  end

  defp join_ids(ids) do
    case Enum.reject(ids, &is_nil/1) do
      [] -> nil
      ids -> Enum.join(ids, " ")
    end
  end

  @doc false
  def input_aria_errormessage(_, []), do: nil
  def input_aria_errormessage(id, _), do: field_errors_id(id)

  @doc false
  def checked?(option, value) when is_list(value) do
    Phoenix.HTML.html_escape(option) in Enum.map(
      value,
      &Phoenix.HTML.html_escape/1
    )
  end

  def checked?(option, value) do
    Phoenix.HTML.html_escape(option) == Phoenix.HTML.html_escape(value)
  end

  @doc false
  def field_errors_id(id) when is_binary(id), do: "#{id}_errors"

  @doc false
  def field_description_id(id) when is_binary(id), do: "#{id}_description"

  @doc false
  def translate_error({msg, opts}, nil) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  def translate_error({msg, opts}, gettext_module)
      when is_atom(gettext_module) do
    if count = opts[:count] do
      # credo:disable-for-next-line
      apply(Gettext, :dngettext, [
        gettext_module,
        "errors",
        msg,
        msg,
        count,
        opts
      ])
    else
      # credo:disable-for-next-line
      apply(Gettext, :dgettext, [gettext_module, "errors", msg, opts])
    end
  end

  ## Helpers

  @doc false
  def humanize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> humanize()
  end

  def humanize(s) when is_binary(s) do
    if String.ends_with?(s, "_id") do
      s |> binary_part(0, byte_size(s) - 3) |> to_titlecase()
    else
      to_titlecase(s)
    end
  end

  defp to_titlecase(s) do
    s
    |> String.replace("_", " ")
    |> :string.titlecase()
  end

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
  def id_fragment(value) do
    value |> to_string() |> String.replace(~r/\s+/u, "-")
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
    if labelled?(label) != labelled?(labelledby) do
      :ok
    else
      raise Doggo.InvalidLabelError,
        component: component,
        example_label: example_label
    end
  end

  defp labelled?(s) when is_binary(s), do: String.trim(s) != ""
  defp labelled?(_), do: false
end
