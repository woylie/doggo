defmodule Doggo.Defaults do
  @moduledoc false

  @doc false
  def split(opts) when is_list(opts) do
    case Keyword.fetch(opts, :defaults) do
      {:ok, defaults} when is_list(defaults) ->
        {literals, expressions} =
          Enum.split_with(defaults, fn {_key, value} ->
            not keyword?(value) and static?(value)
          end)

        {Keyword.put(opts, :defaults, literals), expressions}

      _ ->
        {opts, []}
    end
  end

  def split(opts), do: {opts, []}

  @doc false
  def escape!(builder, literals) do
    for {name, value} <- literals do
      if is_function(value) and Function.info(value, :type) == {:type, :local} do
        raise ArgumentError, """
        invalid default for #{builder}/1

        The default of #{inspect(name)} is an anonymous function, which cannot be
        compiled into the component. Write the expression in the build call
        itself, or use a remote capture such as `&MyAppWeb.Labels.close/0`.
        """
      end

      {name, Macro.escape(value)}
    end
  end

  defp static?(ast), do: Macro.quoted_literal?(ast) or remote_capture?(ast)

  defp keyword?([_ | _] = list),
    do: Enum.all?(list, &match?({key, _} when is_atom(key), &1))

  defp keyword?(_ast), do: false

  defp remote_capture?(
         {:&, _, [{:/, _, [{{:., _, [_module, _fun]}, _, []}, arity]}]}
       )
       when is_integer(arity),
       do: true

  defp remote_capture?(_ast), do: false

  @doc false
  def apply(builder, caller, attrs_and_slots, defaults, modifiers) do
    declarations = declarations(attrs_and_slots)

    defaults =
      for {name, ast} <- defaults do
        declaration = validate_name!(builder, name, declarations, modifiers)
        validate_default!(builder, caller, name, ast, declaration)
        {name, declaration, ast}
      end

    render_code =
      for {name, declaration, ast} <- defaults,
          declaration.kind == :slot or not static?(ast),
          do: default_code(name, ast, declaration)

    {declare(attrs_and_slots, defaults), render_code}
  end

  defp declarations(ast) do
    statements =
      case ast do
        {:__block__, _, statements} -> statements
        statement -> [statement]
      end

    for {kind, _, [name | args]} <- statements,
        kind in [:attr, :slot] and is_atom(name) do
      {name, declaration(kind, args)}
    end
  end

  defp declaration(:attr, [type | rest]) do
    opts = List.first(rest) || []

    %{
      kind: :attr,
      type: type,
      required: opts[:required] == true,
      values: opts[:values]
    }
  end

  defp declaration(:slot, args) do
    opts = Enum.find(args, [], &(is_list(&1) and not Keyword.has_key?(&1, :do)))
    block = Enum.find_value(args, &(is_list(&1) && Keyword.get(&1, :do)))

    %{kind: :slot, required: opts[:required] == true, attrs: slot_attrs(block)}
  end

  defp slot_attrs(nil), do: []

  defp slot_attrs({:__block__, _, statements}),
    do: Enum.flat_map(statements, &slot_attrs/1)

  defp slot_attrs({:attr, _, [name, _type | rest]}) do
    opts = List.first(rest) || []
    [{name, opts[:required] == true}]
  end

  defp slot_attrs(_ast), do: []

  defp validate_name!(builder, name, declarations, modifiers) do
    declaration = declarations[name]

    cond do
      Keyword.has_key?(modifiers, name) ->
        raise ArgumentError, """
        invalid default for #{builder}/1

        #{inspect(name)} is a modifier. Set its default in `modifiers:` instead:

            #{builder}(modifiers: [#{name}: [default: ...]])
        """

      optional?(declaration) ->
        declaration

      true ->
        raise ArgumentError, """
        invalid default for #{builder}/1

        Defaults can be set for optional attributes and slots of the component.

        Got:

            #{inspect(name)}

        Optional attributes and slots:

            #{declarations |> Enum.filter(&optional?(elem(&1, 1))) |> Enum.map_join(", ", &inspect(elem(&1, 0)))}
        """
    end
  end

  defp optional?(%{kind: :attr, type: :global}), do: false
  defp optional?(%{required: required}), do: not required
  defp optional?(nil), do: false

  defp validate_default!(
         builder,
         caller,
         name,
         ast,
         %{kind: :attr} = declaration
       ) do
    cond do
      remote_capture?(ast) ->
        validate_capture!(builder, caller, name, ast)

      not Macro.quoted_literal?(ast) ->
        validate_expression!(builder, name, ast)

      is_list(declaration.values) and
          literal_value(ast) not in declaration.values ->
        raise ArgumentError, """
        invalid default for #{builder}/1

        The default of #{inspect(name)} must be one of the attribute's values.

        Got:

            #{Macro.to_string(ast)}

        Values:

            #{inspect(declaration.values)}
        """

      true ->
        :ok
    end
  end

  defp validate_default!(
         builder,
         caller,
         name,
         ast,
         %{kind: :slot} = declaration
       ) do
    {content, attrs} = slot_default(ast)
    validate_slot_attrs!(builder, name, attrs, declaration.attrs)

    cond do
      remote_capture?(content) ->
        validate_capture!(builder, caller, name, content)

      match?({:sigil_H, _, _}, content) ->
        :ok

      true ->
        raise ArgumentError, """
        invalid default for #{builder}/1

        The content of a slot default is a remote capture of a function
        component, or inline HEEx. For a slot with attributes, pass them with
        the content as `inner_block`:

            #{inspect(name)}: [label: "...", inner_block: ~H"..."]

        Got:

            #{Macro.to_string(ast)}
        """
    end

    for {_attr, attr_ast} <- attrs,
        do: validate_expression!(builder, name, attr_ast)

    :ok
  end

  defp literal_value(ast) do
    {value, _binding} = Code.eval_quoted(ast)
    value
  end

  defp slot_default(ast) do
    if keyword?(ast),
      do: Keyword.pop(ast, :inner_block),
      else: {ast, []}
  end

  defp validate_slot_attrs!(builder, name, attrs, declared) do
    unknown = Keyword.keys(attrs) -- Keyword.keys(declared)

    missing =
      for {attr, true} <- declared, not Keyword.has_key?(attrs, attr), do: attr

    if unknown != [] or missing != [] do
      raise ArgumentError, """
      invalid default for #{builder}/1

      The default of the #{inspect(name)} slot has to set the attributes the slot
      requires, and only attributes the slot declares.

      Missing:

          #{inspect(missing)}

      Unknown:

          #{inspect(unknown)}

      Attributes of the slot:

          #{inspect(Keyword.keys(declared))}
      """
    end
  end

  defp validate_capture!(builder, caller, name, ast) do
    {:&, _, [{:/, _, [{{:., _, [module, fun]}, _, []}, arity]}]} = ast

    exists? =
      not is_atom(module) or module == caller or Module.open?(module) or
        (match?({:module, _}, Code.ensure_compiled(module)) and
           function_exported?(module, fun, arity))

    if not exists? do
      raise ArgumentError, """
      invalid default for #{builder}/1

      The default of #{inspect(name)} refers to a function that does not exist.

      Got:

          #{Macro.to_string(ast)}
      """
    end

    :ok
  end

  defp validate_expression!(builder, name, ast) do
    {_, assigns?} =
      Macro.prewalk(ast, false, fn
        {:sigil_H, _, _}, acc ->
          {nil, acc}

        {:assigns, _, context} = node, _acc when is_atom(context) ->
          {node, true}

        node, acc ->
          {node, acc}
      end)

    if assigns? do
      raise ArgumentError, """
      invalid default for #{builder}/1

      The default of #{inspect(name)} reads the component's assigns. A default
      is evaluated before the component renders and cannot depend on its
      attributes.
      """
    end

    :ok
  end

  defp declare(attrs_and_slots, defaults) do
    defaults = Map.new(defaults, fn {name, _, ast} -> {name, ast} end)

    Macro.prewalk(attrs_and_slots, fn
      {:attr, meta, [name, type, opts]} when is_map_key(defaults, name) ->
        {:attr, meta, [name, type, declare_attr(opts, defaults[name])]}

      {:slot, meta, [name | args]} when is_map_key(defaults, name) ->
        text = "Defaults to `#{Macro.to_string(defaults[name])}`."
        {:slot, meta, [name | slot_doc(args, text)]}

      node ->
        node
    end)
  end

  defp declare_attr(opts, ast) do
    if static?(ast) do
      Keyword.put(opts, :default, ast)
    else
      opts
      |> Keyword.delete(:default)
      |> append_doc(
        "Defaults to `#{Macro.to_string(ast)}`, evaluated at render."
      )
    end
  end

  defp append_doc(opts, text) do
    Keyword.update(opts, :doc, text, &(&1 <> "\n\n" <> text))
  end

  defp slot_doc([], text), do: [[doc: text]]

  defp slot_doc([opts | rest], text) when is_list(opts) do
    if Keyword.has_key?(opts, :do),
      do: [[doc: text], opts | rest],
      else: [append_doc(opts, text) | rest]
  end

  defp default_code(name, ast, %{kind: :slot}) do
    {content, attrs} = slot_default(ast)

    fun =
      case content do
        {:sigil_H, _, _} ->
          quote do
            fn map ->
              var!(assigns) = map
              unquote(content)
            end
          end

        capture ->
          capture
      end

    quote do
      var!(assigns) =
        Doggo.slot_default(var!(assigns), unquote(name), unquote(fun), fn ->
          %{unquote_splicing(attrs)}
        end)
    end
  end

  defp default_code(name, ast, %{kind: :attr}) do
    quote do
      var!(assigns) =
        Doggo.attr_default(var!(assigns), unquote(name), fn ->
          unquote(ast)
        end)
    end
  end
end
