defmodule Doggo.Accessibility do
  @moduledoc """
  Rules checked against every rendered component in the suite.

  Called from `Doggo.TestHelpers.parse_heex/1`, so that they are run on each
  component.

  Use `parse_heex/2` if a component has a legitimate reason to break a rule.
  """

  import ExUnit.Assertions

  @rules [
    :names_on_nameless_elements,
    :nameless_interactive_elements,
    :expanded_state,
    :duplicate_ids
  ]

  @doc """
  Runs every rule against the parsed document.

  Takes a list of rules to skip as the second argument.
  """
  def check(html, except \\ []) do
    for rule <- @rules -- except, do: apply(__MODULE__, rule, [html])
    html
  end

  @doc """
  A `div` or `span` without a role cannot have an accessible name.
  """
  def names_on_nameless_elements(html) do
    offenders =
      for tag <- ~w(div span),
          el <- Floki.find(html, "#{tag}[aria-label], #{tag}[aria-labelledby]"),
          {_, attrs, _} = el,
          not List.keymember?(attrs, "role", 0),
          do: String.slice(Floki.raw_html(el), 0, 120)

    assert offenders == [], """
    A div or span without a role was given an accessible name.

    #{Enum.join(offenders, "\n")}
    """
  end

  @doc """
  A button, link or input needs an accessible name.
  """
  def nameless_interactive_elements(html) do
    wrapped = Floki.find(html, "label input, label button")

    offenders =
      for el <- Floki.find(html, "button, a[href], input:not([type=hidden])"),
          not hidden_from_assistive_technology?(el),
          el not in wrapped,
          not named?(html, el),
          do: String.slice(Floki.raw_html(el), 0, 120)

    assert offenders == [], """
    An interactive element has no accessible name.

    #{Enum.join(offenders, "\n")}
    """
  end

  @doc """
  `aria-expanded` has to agree with the element it controls.
  """
  def expanded_state(html) do
    offenders =
      for el <- Floki.find(html, "[aria-expanded][aria-controls]"),
          {_, attrs, _} = el,
          {_, expanded} = List.keyfind(attrs, "aria-expanded", 0),
          {_, controls} = List.keyfind(attrs, "aria-controls", 0),
          target = Floki.find(html, "##{controls}"),
          target != [],
          hidden?(target) == (expanded == "true"),
          do:
            "#{String.slice(Floki.raw_html(el), 0, 100)} controls ##{controls}"

    assert offenders == [], """
    An `aria-expanded` state disagrees with the element it controls.

    #{Enum.join(offenders, "\n")}
    """
  end

  defp hidden?(elements) do
    Enum.all?(elements, fn {_, attrs, _} ->
      List.keymember?(attrs, "hidden", 0)
    end)
  end

  @doc """
  Two elements in one document cannot share an id.
  """
  def duplicate_ids(html) do
    duplicates =
      html
      |> Floki.attribute("id")
      |> Enum.frequencies()
      |> Enum.filter(fn {_, count} -> count > 1 end)
      |> Enum.map(fn {id, count} -> "  #{id} — #{count} times" end)

    assert duplicates == [], """
    The same id is used more than once in one document.

    #{Enum.join(duplicates, "\n")}
    """
  end

  defp hidden_from_assistive_technology?({_, attrs, _}) do
    List.keyfind(attrs, "aria-hidden", 0) == {"aria-hidden", "true"}
  end

  defp named?(html, {_, attrs, children} = el) do
    has_attr?(attrs, "aria-label") or has_attr?(attrs, "aria-labelledby") or
      String.trim(Floki.text(el)) != "" or
      Enum.any?(children, &labelled_child?/1) or
      labelled_by_element?(html, attrs)
  end

  defp labelled_by_element?(html, attrs) do
    case List.keyfind(attrs, "id", 0) do
      {_, id} -> Floki.find(html, "label[for='#{id}']") != []
      nil -> false
    end
  end

  defp labelled_child?({_, attrs, _}), do: has_attr?(attrs, "aria-label")
  defp labelled_child?(_), do: false

  defp has_attr?(attrs, name) do
    case List.keyfind(attrs, name, 0) do
      {_, value} -> String.trim(value) != ""
      nil -> false
    end
  end
end
