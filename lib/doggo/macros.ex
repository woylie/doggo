defmodule Doggo.Macros do
  @moduledoc false
  use Phoenix.Component

  defmacro component(name) do
    module = component_module(name)
    builder_name = :"build_#{name}"
    config = module.config()

    opts =
      Keyword.validate!(config, [
        :base_class,
        :extra,
        :maturity,
        :maturity_note,
        :modifiers,
        :since,
        :type
      ])

    modifiers = Keyword.fetch!(opts, :modifiers)
    extra = Keyword.get(opts, :extra, [])
    base_class = Keyword.get(opts, :base_class, default_base_class(name))

    defaults =
      [
        name: opts[:name] || name,
        base_class: base_class,
        modifiers: modifiers,
        class_name_fun: &Doggo.modifier_class_name/2
      ] ++ extra

    type = Keyword.fetch!(opts, :type)
    since = Keyword.fetch!(opts, :since)
    docstring = assemble_builder_doc(module, builder_name, defaults, opts)

    quote do
      @doc unquote(docstring)
      @doc type: unquote(type)
      @doc since: unquote(since)

      defmacro unquote(builder_name)(opts \\ []) do
        module = unquote(module)
        opts = Keyword.validate!(opts, unquote(defaults))

        {opts, extra} =
          Keyword.split(opts, [:name, :base_class, :modifiers, :class_name_fun])

        component_info =
          opts
          |> Keyword.put(:component, unquote(name))
          |> Keyword.put(:type, unquote(type))

        name = Keyword.fetch!(opts, :name)
        modifiers = Keyword.fetch!(opts, :modifiers)
        modifier_names = Keyword.keys(modifiers)
        attrs_and_slots = module.attrs_and_slots()
        docstring = Doggo.Macros.assemble_component_doc(module)

        quote do
          @dog_components unquote(component_info)

          @doc unquote(docstring)

          for {name, modifier_opts} <- unquote(modifiers) do
            attr name, :string, modifier_opts
          end

          attr :class, :any,
            default: nil,
            doc: """
            Any additional classes to be added.

            Variations of the component should be expressed via modifier
            attributes, and it is preferable to use styles on the parent
            container to arrange components on the page, but if you have to,
            you can use this attribute to pass additional utility classes to
            the component.

            The value can be a string or a list of strings.
            """

          unquote(attrs_and_slots)

          def unquote(name)(var!(assigns)) do
            unquote(prepare_class(opts))
            unquote(module.init_block(opts, extra))
            unquote(module).render(var!(assigns))
          end
        end
      end
    end
  end

  defp component_module(name) when is_atom(name) do
    module_name = name |> Atom.to_string() |> Macro.camelize()
    Module.concat([Doggo.Components, module_name])
  end

  defp default_base_class(name) when is_atom(name) do
    name |> to_string |> String.replace("_", "-")
  end

  defp assemble_builder_doc(module, builder_name, defaults, opts) do
    doc = module.doc()
    usage = module.usage()

    builder_doc =
      if function_exported?(module, :builder_doc, 0) do
        """
        In addition to the [common options](`m:Doggo.Components#module-common-options`)
        `name`, `base_class`, `modifiers`, and `class_name_fun`, the build macro
        also supports the following options.

        #{module.builder_doc()}
        """
      else
        """
        The build macro supports the [common options](`m:Doggo.Components#module-common-options`)
        `name`, `base_class`, `modifiers`, and `class_name_fun`.
        """
      end

    maturity = Keyword.fetch!(opts, :maturity)
    maturity_note = Keyword.get(opts, :maturity_note)
    maturity_info_block = build_maturity_info(maturity, maturity_note)

    [
      doc,
      maturity_info_block,
      """
      ## Configuration

      Generate the component with default options:

          #{to_string(builder_name)}()
      """,
      builder_doc,
      """
      ### Default options

      ```elixir
      #{inspect(defaults, pretty: true)}
      ```
      """,
      """
      ## Usage

      #{usage}
      """,
      css_example_doc(module)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
  end

  def assemble_component_doc(module) do
    usage = module.usage()
    doc = module.doc()

    """
    #{doc}

    ## Usage

    #{usage}
    """
  end

  defp css_example_doc(module) do
    if function_exported?(module, :css_path, 0) do
      base_url = "https://github.com/woylie/doggo/blob/main/demo/assets/css/"
      url = base_url <> module.css_path()

      """
      ## Example CSS

      For example CSS, you can have a look at the [demo styles](#{url}).
      """
    end
  end

  defp build_maturity_info(maturity, nil) do
    """
    > #### Maturity: #{maturity_to_string(maturity)} {: .info}
    """
  end

  defp build_maturity_info(maturity, note) do
    """
    > #### Maturity: #{maturity_to_string(maturity)} {: .info}
    >
    #{quote_note(note)}
    """
  end

  defp maturity_to_string(maturity)
       when maturity in [:experimental, :developing, :refining, :stable] do
    maturity |> to_string() |> String.capitalize()
  end

  defp quote_note(note) do
    note
    |> String.split("\n")
    |> Enum.map_join("\n", &String.trim("> #{&1}"))
  end

  def prepare_class(opts) do
    modifiers = Keyword.fetch!(opts, :modifiers)
    modifier_names = Keyword.keys(modifiers)
    base_class = Keyword.fetch!(opts, :base_class)
    class_name_fun = Keyword.fetch!(opts, :class_name_fun)

    quote do
      var!(assigns) =
        assign(var!(assigns),
          base_class: unquote(base_class),
          class:
            Doggo.build_class(
              unquote(base_class),
              unquote(modifier_names),
              unquote(class_name_fun),
              var!(assigns)
            )
        )
    end
  end

  def unpack_heex(heex, extra) when is_function(heex), do: heex.(extra)
  def unpack_heex(heex, _), do: heex

  def unpack_component_function(fun, opts, extra) when is_function(fun),
    do: fun.(opts, extra)

  def unpack_component_function(fun, _, _), do: fun
end
