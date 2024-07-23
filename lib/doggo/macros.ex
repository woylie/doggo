defmodule Doggo.Macros do
  @moduledoc false
  use Phoenix.Component

  defmacro component(name, opts) do
    opts =
      Keyword.validate!(opts, [
        :attrs_and_slots,
        :base_class,
        :doc,
        :extra,
        :heex,
        :maturity,
        :maturity_note,
        :modifiers,
        :name,
        :since,
        :type,
        :usage
      ])

    builder_name = :"build_#{name}"
    maturity = Keyword.fetch!(opts, :maturity)
    maturity_note = Keyword.get(opts, :maturity_note)
    doc = Keyword.fetch!(opts, :doc)
    usage = Keyword.fetch!(opts, :usage)
    modifiers = Keyword.fetch!(opts, :modifiers)
    extra = Keyword.get(opts, :extra, [])

    base_class =
      Keyword.get(
        opts,
        :base_class,
        name |> to_string |> String.replace("_", "-")
      )

    defaults =
      [
        name: opts[:name] || name,
        base_class: base_class,
        modifiers: modifiers,
        class_name_fun: &Doggo.modifier_class_name/2
      ] ++ extra

    type = Keyword.fetch!(opts, :type)
    since = Keyword.fetch!(opts, :since)
    attrs_and_slots = Keyword.fetch!(opts, :attrs_and_slots)
    heex = Keyword.fetch!(opts, :heex)

    maturity_info = build_maturity_info(maturity, maturity_note)

    quote do
      @doc """
      #{unquote(doc)}

      #{unquote(maturity_info)}

      ## Generate Component

      Generate component with default options:

          #{unquote(to_string(builder_name))}()

      ## Default options

      ```elixir
      #{unquote(inspect(defaults, pretty: true))}
      ```

      ## Usage

      #{unquote(usage)}
      """

      @doc type: unquote(type)
      @doc since: unquote(since)

      defmacro unquote(builder_name)(opts \\ []) do
        opts = Keyword.validate!(opts, unquote(defaults))

        {opts, extra} =
          Keyword.split(opts, [:name, :base_class, :modifiers, :class_name_fun])

        component_info =
          opts
          |> Keyword.put(:component, unquote(name))
          |> Keyword.put(:type, unquote(type))

        name = Keyword.fetch!(opts, :name)
        base_class = Keyword.fetch!(opts, :base_class)
        modifiers = Keyword.fetch!(opts, :modifiers)
        modifier_names = Keyword.keys(modifiers)
        class_name_fun = Keyword.fetch!(opts, :class_name_fun)
        heex = Doggo.Macros.unpack_heex(unquote(heex), extra)
        attrs_and_slots = unquote(attrs_and_slots)
        usage = unquote(usage)
        doc = unquote(doc)

        quote do
          @dog_components unquote(component_info)

          @doc """
          #{unquote(doc)}

          ## Usage

          #{unquote(usage)}
          """

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

            unquote(heex)
          end
        end
      end
    end
  end

  def unpack_heex(heex, extra) when is_function(heex), do: heex.(extra)
  def unpack_heex(heex, _), do: heex

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
end
