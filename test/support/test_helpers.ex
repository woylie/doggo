defmodule Doggo.TestHelpers do
  @moduledoc """
  Defines helpers for tests.
  """

  import Phoenix.LiveViewTest

  @doc """
  Renders the given HEEx template and parses it with Floki.

  ## Example

      parse_heex(~H"<p>Hello!</p>")
  """
  def parse_heex(heex) do
    heex
    |> rendered_to_string()
    |> Floki.parse_fragment!()
  end

  @doc """
  Returns the trimmed text nodes from the first level of the HTML tree.
  """
  def text(html) do
    html
    |> Floki.text(deep: false)
    |> String.trim()
  end

  @doc """
  Returns the trimmed text nodes from the first level of the HTML tree returned
  by the selector.

  Raises if the selector returns zero or more than one result.
  """
  def text(html, selector) do
    html
    |> find_one(selector)
    |> Floki.text(deep: false)
    |> String.trim()
  end

  @doc """
  Wrapper around `Floki.attribute/2` that unwraps the single attribute.

  Raises if the attribute occurs multiple times.
  """
  def attribute(html, name) do
    case Floki.attribute(html, name) do
      [value] -> value
      [] -> nil
      _ -> raise "found attribute #{name} multiple times"
    end
  end

  @doc """
  Wrapper around `Floki.attribute/3` that unwraps the single attribute.

  Raises if the attribute occurs multiple times.
  """
  def attribute(html, selector, name) do
    html
    |> find_one(selector)
    |> attribute(name)
  end

  def find_one(html, selector) do
    case Floki.find(html, selector) do
      [inner_html] ->
        inner_html

      [] ->
        raise """
        Selector #{inspect(selector)} did not return any results in:

        #{inspect(html, pretty: true)}
        """

      [_ | _] = results ->
        raise """
        Selector #{inspect(selector)} returned multiple results:

        #{inspect(results, pretty: true)}
        """
    end
  end
end
