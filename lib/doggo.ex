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
    JS.dispatch(js, "doggo:close", to: "##{id}")
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
    JS.dispatch(js, "doggo:open", to: "##{id}")
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
    JS.dispatch(js, "doggo:show-tab", to: "##{id}", detail: %{index: index})
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
      to: "##{id}-trigger-#{index}"
    )
    |> JS.toggle_attribute({"hidden", ""},
      to: "##{id}-section-#{index}"
    )
  end

  @doc false
  def toggle_disclosure(target_id) when is_binary(target_id) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"})
    |> JS.toggle_attribute({"hidden", ""}, to: "##{target_id}")
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
  def ensure_label!(%{label: s, labelledby: nil}, _, _) when is_binary(s) do
    :ok
  end

  def ensure_label!(%{label: nil, labelledby: s}, _, _) when is_binary(s) do
    :ok
  end

  def ensure_label!(_, component, example_label) do
    raise Doggo.InvalidLabelError,
      component: component,
      example_label: example_label
  end
end
