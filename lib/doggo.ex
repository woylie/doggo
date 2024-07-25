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
    <<date::10-binary, _::binary>> = struct.to_string(value)
    {:safe, date}
  end

  def normalize_value("date", <<date::10-binary, _::binary>>) do
    {:safe, date}
  end

  def normalize_value("date", _), do: ""
  def normalize_value(type, value), do: Form.normalize_value(type, value)

  @doc false
  def input_aria_describedby(_, []), do: nil
  def input_aria_describedby(id, _), do: field_description_id(id)

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

  ## Example

  ```heex
  <.link phx-click={hide_modal("pet-modal")}>hide</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.remove_attribute("open", to: "##{id}")
    |> JS.set_attribute({"aria-modal", "false"}, to: "##{id}")
    |> JS.pop_focus()
  end

  @doc """
  Shows the modal with the given ID.

  ## Example

  ```heex
  <.link phx-click={show_modal("pet-modal")}>show</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.push_focus()
    |> JS.set_attribute({"open", "true"}, to: "##{id}")
    |> JS.set_attribute({"aria-modal", "true"}, to: "##{id}")
    |> JS.focus_first(to: "##{id}-content")
  end

  @doc """
  Shows the tab with the given index of the `tabs/1` component with the given
  ID.

  ## Example

      Doggo.show_tab("my-tabs", 2)
  """
  @doc type: :js
  @doc since: "0.5.0"

  def show_tab(js \\ %JS{}, id, index)
      when is_binary(id) and is_integer(index) do
    other_tabs = "##{id} [role='tab']:not(##{id}-tab-#{index})"
    other_panels = "##{id} [role='tabpanel']:not(##{id}-panel-#{index})"

    js
    |> JS.set_attribute({"aria-selected", "true"}, to: "##{id}-tab-#{index}")
    |> JS.set_attribute({"tabindex", "0"}, to: "##{id}-tab-#{index}")
    |> JS.remove_attribute("hidden", to: "##{id}-panel-#{index}")
    |> JS.set_attribute({"aria-selected", "false"}, to: other_tabs)
    |> JS.set_attribute({"tabindex", "-1"}, to: other_tabs)
    |> JS.set_attribute({"hidden", "hidden"}, to: other_panels)
  end

  @doc false
  def toggle_accordion_section(id, index)
      when is_binary(id) and is_integer(index) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"},
      to: "##{id}-trigger-#{index}"
    )
    |> JS.toggle_attribute({"hidden", "hidden"},
      to: "##{id}-section-#{index}"
    )
  end

  @doc false
  def toggle_disclosure(target_id) when is_binary(target_id) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"})
    |> JS.toggle_attribute({"hidden", "hidden"}, to: "##{target_id}")
  end

  ## Modifier classes

  @doc """
  Takes a modifier attribute name and value and returns a CSS class name.

  This function is used as a default for the `class_name_fun` option.

  ## Example

      iex> modifier_class_name(:size, "large")
      "is-large"
  """
  @spec modifier_class_name(atom, String.t()) :: String.t()
  def modifier_class_name(_, value) when is_binary(value), do: "is-#{value}"

  @doc """
  Returns all modifier classes defined in the given components module.

  ## Usage

      iex> modifier_classes(MyAppWeb.CoreComponents)
      [
        "is-large",
        "is-medium",
        "is-primary",
        "is-secondary",
        "is-small"
      ]
  """
  @spec modifier_classes(module) :: [String.t()]
  def modifier_classes(module) when is_atom(module) do
    module.__dog_components__()
    |> Enum.flat_map(&get_modifier_classes/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp get_modifier_classes({_, info}) do
    class_name_fun = Keyword.fetch!(info, :class_name_fun)

    info
    |> Keyword.fetch!(:modifiers)
    |> Enum.flat_map(fn {name, modifier_opts} ->
      modifier_opts
      |> Keyword.fetch!(:values)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&class_name_fun.(name, &1))
    end)
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
