defmodule Doggo.Template do
  @moduledoc false

  @placeholder ~r/(?<=\s)([\w.-]+)=\{Doggo\.build\(:(\w+)(?:, "([^"{}]*)")?\)\}/
  @module_root ~r/(?<![\w.])([A-Z]\w*)\./
  @callee_tag ~r/<(\/?)Doggo\.Callee\.(\w+)/

  @doc false
  def compile(module, values) do
    {template, roots} =
      Macro.prewalk(module.template(values), [], &inject(&1, &2, values))

    aliases =
      for root <- Enum.uniq(roots) do
        quote do: alias(unquote(Module.concat([root])), warn: false)
      end

    quote do
      unquote_splicing(aliases)
      require Doggo
      unquote(template)
    end
  end

  @doc false
  def fetch!(values, key) do
    case Keyword.fetch(values, key) do
      {:ok, value} ->
        value

      :error ->
        raise ArgumentError, """
        unknown build option in template

        A component's template reads a build option that the build does not
        have.

        Got:

            #{inspect(key)}
        """
    end
  end

  defp inject(
         {:sigil_H, meta, [{:<<>>, string_meta, [source]}, modifiers]},
         roots,
         values
       ) do
    source =
      Regex.replace(@callee_tag, source, fn _, slash, key ->
        "<#{slash}#{callee_tag(fetch!(values, String.to_atom(key)))}"
      end)

    source =
      Regex.replace(@placeholder, source, fn match, name, key, suffix ->
        values
        |> fetch!(String.to_atom(key))
        |> static_value(suffix)
        |> placeholder_text(name, match)
      end)

    roots = roots ++ Enum.map(Regex.scan(@module_root, source), &Enum.at(&1, 1))
    {{:sigil_H, meta, [{:<<>>, string_meta, [source]}, modifiers]}, roots}
  end

  defp inject(ast, roots, _values), do: {ast, roots}

  defp callee_tag(fun) do
    {module, name} = Doggo.capture_name(fun)

    if not Regex.match?(~r/^[a-z_][a-zA-Z0-9_]*$/, Atom.to_string(name)) do
      raise ArgumentError, """
      invalid callee name

      The name of a component that another component renders has to be a
      valid HEEx tag name.

      Got:

          #{inspect(fun)}
      """
    end

    "#{inspect(module)}.#{name}"
  end

  defp static_value(value, suffix) when is_binary(value) do
    value = value <> suffix
    if String.contains?(value, ~w(" ' < > & { })), do: nil, else: value
  end

  defp static_value(_value, _suffix), do: nil

  defp placeholder_text(nil, _name, match), do: match
  defp placeholder_text(value, name, _match), do: ~s(#{name}="#{value}")
end
