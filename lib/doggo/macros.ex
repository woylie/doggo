defmodule Doggo.Macros do
  @moduledoc false
  use Phoenix.Component

  defmacro component(name, opts) do
    opts =
      Keyword.validate!(opts, [
        :base_class,
        :modifiers,
        :doc,
        :usage,
        :type,
        :since,
        :attrs_and_slots,
        :type,
        :since,
        :heex
      ])

    doc = Keyword.fetch!(opts, :doc)
    usage = Keyword.fetch!(opts, :usage)
    modifiers = Keyword.fetch!(opts, :modifiers)

    base_class =
      Keyword.get(
        opts,
        :base_class,
        name |> to_string |> String.replace("_", "-")
      )

    defaults =
      [
        name: name,
        base_class: base_class,
        modifiers: modifiers,
        class_name_fun: &Doggo.modifier_class_name/1
      ]

    type = Keyword.fetch!(opts, :type)
    since = Keyword.fetch!(opts, :since)
    attrs_and_slots = Keyword.fetch!(opts, :attrs_and_slots)
    heex = Keyword.fetch!(opts, :heex)

    quote do
      @doc """
      #{unquote(doc)}

      ## Generate Component

      Generate component with default options:

          #{unquote(to_string(name))}()

      ## Default options

      ```elixir
      #{unquote(inspect(defaults, pretty: true))}
      ```

      ## Usage

      #{unquote(usage)}
      """

      @doc type: unquote(type)
      @doc since: unquote(since)

      defmacro unquote(name)(opts \\ []) do
        opts = Keyword.validate!(opts, unquote(defaults))

        name = Keyword.fetch!(opts, :name)
        base_class = Keyword.fetch!(opts, :base_class)
        modifiers = Keyword.fetch!(opts, :modifiers)
        modifier_names = Keyword.keys(modifiers)
        class_name_fun = Keyword.fetch!(opts, :class_name_fun)
        heex = unquote(heex)
        attrs_and_slots = unquote(attrs_and_slots)
        usage = unquote(usage)
        doc = unquote(doc)

        quote do
          @doc """
          #{unquote(doc)}

          ## Usage

          #{unquote(usage)}
          """

          for {name, modifier_opts} <- unquote(modifiers) do
            attr name, :string, modifier_opts
          end

          unquote(attrs_and_slots)

          def unquote(name)(var!(assigns)) do
            var!(assigns) =
              assign(var!(assigns),
                base_class: unquote(base_class),
                modifier_classes:
                  Doggo.Components.modifier_classes(
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
end
