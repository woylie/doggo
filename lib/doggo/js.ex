defmodule Doggo.JS do
  @moduledoc """
  Commands for the JavaScript hooks of the components, to use in `phx-click`
  and other bindings.
  """

  alias Phoenix.LiveView.JS

  @doc """
  Hides the modal with the given ID.

  The component needs its JavaScript hook registered, since this function uses
  the hook to call `close()` on the dialog.

  ## Example

  ```heex
  <.link phx-click={Doggo.JS.hide_modal("pet-modal")}>hide</.link>
  ```
  """
  @doc since: "0.18.0"
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
  <.link phx-click={Doggo.JS.show_modal("pet-modal")}>show</.link>
  ```
  """
  @doc since: "0.18.0"
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

      Doggo.JS.show_tab("my-tabs", 2)
  """
  @doc since: "0.18.0"
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
end
