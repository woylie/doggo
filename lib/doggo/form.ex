defmodule Doggo.Form do
  @moduledoc """
  Helpers for building custom form controls with the same ids and ARIA
  attributes as the `field` component.
  """

  alias Phoenix.HTML

  @doc """
  Returns the id of the error list of the field with the given input id.

  ## Example

      iex> Doggo.Form.field_errors_id("pet-name")
      "pet-name-errors"
  """
  @doc since: "0.18.0"
  @spec field_errors_id(String.t()) :: String.t()
  def field_errors_id(id) when is_binary(id), do: "#{id}-errors"

  @doc """
  Returns the id of the description of the field with the given input id.

  ## Example

      iex> Doggo.Form.field_description_id("pet-name")
      "pet-name-description"
  """
  @doc since: "0.18.0"
  @spec field_description_id(String.t()) :: String.t()
  def field_description_id(id) when is_binary(id), do: "#{id}-description"

  @doc """
  Returns the `aria-describedby` value of an input: the ids of the error list
  and the description, if the field has them, or `nil`.

  `description` and `errors` are lists, such as the entries of a description
  slot and the error messages. The id of the error list comes first, as in the
  markup of `field`.

  The id of the error list is also the `aria-errormessage` value (see
  `input_aria_errormessage/2`). It is included here as well, since screen
  readers support `aria-errormessage` inconsistently.

  ## Examples

      iex> Doggo.Form.input_aria_describedby("pet-name", [], [])
      nil

      iex> Doggo.Form.input_aria_describedby("pet-name", [], ["is too short"])
      "pet-name-errors"

      iex> Doggo.Form.input_aria_describedby("pet-name", ["Your pet's name"], [])
      "pet-name-description"

      iex> Doggo.Form.input_aria_describedby(
      ...>   "pet-name",
      ...>   ["Your pet's name"],
      ...>   ["is too short"]
      ...> )
      "pet-name-errors pet-name-description"
  """
  @doc since: "0.18.0"
  @spec input_aria_describedby(String.t(), list(), list()) :: String.t() | nil
  def input_aria_describedby(_id, [], []), do: nil
  def input_aria_describedby(id, [], _errors), do: field_errors_id(id)
  def input_aria_describedby(id, _description, []), do: field_description_id(id)

  def input_aria_describedby(id, _description, _errors) do
    "#{field_errors_id(id)} #{field_description_id(id)}"
  end

  @doc """
  Returns the `aria-errormessage` value of an input: the id of the error list
  if there are errors, or `nil`.

  ## Example

      iex> Doggo.Form.input_aria_errormessage("pet-name", ["is too short"])
      "pet-name-errors"
  """
  @doc since: "0.18.0"
  @spec input_aria_errormessage(String.t(), list()) :: String.t() | nil
  def input_aria_errormessage(_, []), do: nil
  def input_aria_errormessage(id, _), do: field_errors_id(id)

  @doc """
  Interpolates the values of an error into its message, without translating
  it.

  This is the default of the `translate_error` build option of `field`.

  ## Example

      iex> Doggo.Form.translate_error({"must have %{count} items", [count: 3]})
      "must have 3 items"
  """
  @doc since: "0.18.0"
  @spec translate_error({String.t(), keyword()}) :: String.t()
  def translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  @doc false
  def normalize_value("date", %struct{} = value)
      when struct in [Date, NaiveDateTime, DateTime] do
    value |> Doggo.Time.to_date() |> Date.to_iso8601()
  end

  def normalize_value("date", <<date::10-binary, _::binary>>) do
    case Date.from_iso8601(date) do
      {:ok, _} -> date
      {:error, _} -> ""
    end
  end

  def normalize_value("date", _), do: ""

  def normalize_value(type, value) do
    HTML.Form.normalize_value(type, value)
  end

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
        "#{assigns.id}_#{id_fragment(assigns.option_value)}-description"
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
  def checked?(option, value) when is_list(value) do
    HTML.html_escape(option) in Enum.map(
      value,
      &HTML.html_escape/1
    )
  end

  def checked?(option, value) do
    HTML.html_escape(option) == HTML.html_escape(value)
  end

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

  @doc false
  def id_fragment(value) do
    {:safe, value} = HTML.html_escape(value)
    value |> IO.iodata_to_binary() |> String.replace(~r/\W/u, "_")
  end
end
