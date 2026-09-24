defmodule Doggo.Macros do
  @moduledoc false
  use Phoenix.Component

  @version Mix.Project.config()[:version]

  defmacro component(name) do
    module = component_module(name)
    builder_name = :"build_#{name}"
    config = module.config()

    opts =
      Keyword.validate!(config, [
        :base_class,
        :data_attrs,
        :extra,
        :maturity,
        :maturity_note,
        :modifiers,
        :since,
        :type
      ])

    modifiers = Keyword.fetch!(opts, :modifiers)
    data_attrs = Keyword.get(opts, :data_attrs, [])
    extra = Keyword.get(opts, :extra, [])
    base_class = Keyword.get(opts, :base_class, default_base_class(name))

    defaults =
      [
        name: opts[:name] || name,
        base_class: base_class,
        modifiers: modifiers
      ] ++ extra

    type = Keyword.fetch!(opts, :type)
    since = Keyword.fetch!(opts, :since)
    docstring = assemble_builder_doc(module, builder_name, defaults, opts)

    quote do
      @doc unquote(docstring)
      @doc type: unquote(type)
      @doc since: unquote(since)

      defmacro unquote(builder_name)(opts \\ []) do
        opts =
          if Keyword.has_key?(opts, :icon_module) do
            Keyword.update!(opts, :icon_module, &Macro.expand(&1, __CALLER__))
          else
            opts
          end

        module = unquote(module)
        opts = Keyword.validate!(opts, unquote(defaults))

        {opts, extra} =
          Keyword.split(opts, [:name, :base_class, :data_attrs, :modifiers])

        attrs_and_slots = module.attrs_and_slots(extra)

        Doggo.Macros.validate_build!(unquote(name), opts, attrs_and_slots)

        component_info =
          opts
          |> Keyword.put(:component, unquote(name))
          |> Keyword.put(:data_attrs, unquote(data_attrs))
          |> Keyword.put(:extra, extra)
          |> Keyword.put(:type, unquote(type))

        name = Keyword.fetch!(opts, :name)
        modifiers = Keyword.fetch!(opts, :modifiers)
        docstring = Doggo.Macros.assemble_component_doc(module)

        quote do
          Doggo.Macros.validate_module!(
            unquote(component_info[:component]),
            __ENV__
          )

          @dog_components unquote(component_info)

          @doc unquote(docstring)
          @doc type: unquote(component_info[:type])

          for {name, modifier_opts} <- unquote(modifiers) do
            {type, modifier_opts} = Keyword.pop(modifier_opts, :type, :string)
            attr name, type, modifier_opts
          end

          attr :class, :any,
            default: [],
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
            unquote(label_check(module, name))
            unquote(prepare_class_and_data_attrs(opts))
            unquote(module.init_block(opts, extra))
            unquote(module).render(var!(assigns))
          end
        end
      end
    end
  end

  @global_attributes ~w(
    accesskey anchor autocapitalize autocorrect autofocus class contenteditable
    dir draggable enterkeyhint exportparts hidden id inert inputmode is itemid
    itemprop itemref itemscope itemtype lang nonce onabort onautocomplete
    onautocompleteerror onblur oncancel oncanplay oncanplaythrough onchange
    onclick onclose oncontextmenu oncuechange ondblclick ondrag ondragend
    ondragenter ondragleave ondragover ondragstart ondrop ondurationchange
    onemptied onended onerror onfocus oninput oninvalid onkeydown onkeypress
    onkeyup onload onloadeddata onloadedmetadata onloadstart onmousedown
    onmouseenter onmouseleave onmousemove onmouseout onmouseover onmouseup
    onmousewheel onpause onplay onplaying onprogress onratechange onreset
    onresize onscroll onseeked onseeking onselect onshow onsort onstalled
    onsubmit onsuspend ontimeupdate ontoggle onvolumechange onwaiting part
    popover role slot spellcheck style tabindex title translate
    virtualkeyboardpolicy writingsuggestions xml:base xml:lang
  )

  @global_prefixes ~w(aria- data- phx-)

  @phoenix_component_imports for {name, 1} <-
                                   Phoenix.Component.__info__(:functions) ++
                                     Phoenix.Component.__info__(:macros),
                                 do: name

  @doc false
  def validate_build!(component, opts, attrs_and_slots) do
    builder = :"build_#{component}"
    name = Keyword.fetch!(opts, :name)
    modifiers = Keyword.fetch!(opts, :modifiers)

    if name in @phoenix_component_imports do
      raise ArgumentError, """
      #{builder}/1 cannot generate a function called #{name}/1

      Phoenix.Component imports a function with the same name and arity. Please
      choose a different name:

          #{builder}(name: :my_#{name})
      """
    end

    declared = [:class | declared_names(attrs_and_slots)]

    for {modifier, _} <- modifiers do
      validate_modifier!(builder, modifier, declared)
    end

    :ok
  end

  @doc false
  def validate_module!(component, env) do
    if not Module.has_attribute?(env.module, :dog_components) do
      raise ArgumentError, """
      build_#{component}/1 must be called in a module that uses Doggo.Components

          defmodule MyAppWeb.CoreComponents do
            use Doggo.Components
            use Phoenix.Component

            build_#{component}()
          end
      """
    end

    :ok
  end

  defp validate_modifier!(builder, modifier, declared) do
    cond do
      global_attribute?(to_string(modifier)) ->
        raise ArgumentError, """
        #{builder}/1 cannot use #{inspect(modifier)} as a modifier name

        #{modifier} is a global HTML attribute and cannot be used as a modifier.
        Please choose a different name.
        """

      modifier in declared ->
        raise ArgumentError, """
        #{builder}/1 cannot use #{inspect(modifier)} as a modifier name

        The component already declares an attribute or slot with that name.
        Please choose another name for the modifier.

            modifier: #{inspect(modifier)}
        """

      true ->
        :ok
    end
  end

  defp global_attribute?(name) do
    name in @global_attributes or String.starts_with?(name, @global_prefixes)
  end

  defp declared_names(attrs_and_slots) do
    {_, names} =
      Macro.prewalk(attrs_and_slots, [], fn
        {:attr, _, [name | _]}, acc when is_atom(name) -> {nil, [name | acc]}
        {:slot, _, [name | _]}, acc when is_atom(name) -> {nil, [name | acc]}
        node, acc -> {node, acc}
      end)

    names
  end

  defp component_module(name) when is_atom(name) do
    module_name = name |> Atom.to_string() |> Macro.camelize()
    Module.concat([Doggo.Components, module_name])
  end

  defp default_base_class(name) when is_atom(name) do
    name |> to_string() |> String.replace("_", "-")
  end

  defp assemble_builder_doc(module, builder_name, defaults, opts) do
    doc = module.doc()
    usage = module.usage()

    builder_doc =
      if function_exported?(module, :builder_doc, 0) do
        """
        In addition to the [common options](`m:Doggo.Components#module-common-options`)
        `name`, `base_class`, and `modifiers`, the build macro
        also supports the following options.

        #{module.builder_doc()}
        """
      else
        """
        The build macro supports the [common options](`m:Doggo.Components#module-common-options`)
        `name`, `base_class`, and `modifiers`.
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
      keyboard_doc(module),
      css_example_doc(module)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
  end

  def assemble_component_doc(module) do
    usage = module.usage()
    doc = module.doc()
    config = module.config()

    [
      doc,
      build_maturity_block(
        Keyword.fetch!(config, :maturity),
        Keyword.get(config, :maturity_note)
      ),
      """
      ## Usage

      #{usage}
      """,
      keyboard_doc(module)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
  end

  defp keyboard_doc(module) do
    if function_exported?(module, :keyboard, 0) do
      """
      ## Keyboard

      #{module.keyboard()}
      """
    end
  end

  defp css_example_doc(module) do
    if function_exported?(module, :css_path, 0) do
      base_url =
        "https://github.com/woylie/doggo/blob/#{@version}/assets/css/"

      url = base_url <> module.css_path()

      """
      ## Example CSS

      For example CSS, you can have a look at the [demo styles](#{url}).
      """
    end
  end

  defp build_maturity_info(maturity, note) do
    maturity_block(
      "#### Maturity: #{maturity_to_string(maturity)} {: .info}",
      note
    )
  end

  defp build_maturity_block(maturity, note) do
    maturity_block("**Maturity: #{maturity_to_string(maturity)}**", note)
  end

  defp maturity_block(heading, nil) do
    """
    > #{heading}
    """
  end

  defp maturity_block(heading, note) do
    """
    > #{heading}
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

  @doc false
  def label_check(module, name) do
    if function_exported?(module, :example_label, 0) do
      quote do
        Doggo.ensure_label!(
          var!(assigns),
          unquote(".#{name}"),
          unquote(module.example_label())
        )
      end
    end
  end

  def prepare_class_and_data_attrs(opts) do
    modifiers = Keyword.fetch!(opts, :modifiers)
    modifier_names = Keyword.keys(modifiers)
    base_class = Keyword.fetch!(opts, :base_class)

    quote do
      additional_classes =
        if value = var!(assigns)[:class], do: List.wrap(value), else: []

      unquote(combine_classes(base_class))
      unquote(build_data_attrs(modifier_names))

      var!(assigns) =
        assign(var!(assigns), base_class: unquote(base_class), class: class)
    end
  end

  defp combine_classes(nil) do
    quote do
      class = additional_classes
    end
  end

  defp combine_classes(base_class) do
    quote do
      class = [unquote(base_class) | additional_classes]
    end
  end

  defp build_data_attrs([]) do
    quote do
      var!(assigns) = assign(var!(assigns), :data_attrs, [])
    end
  end

  defp build_data_attrs(modifier_names) do
    quote do
      {modifier_assigns, var!(assigns)} =
        Map.split(var!(assigns), unquote(modifier_names))

      var!(assigns) =
        assign(var!(assigns), :data_attrs, %{
          data: Keyword.new(modifier_assigns)
        })
    end
  end
end
