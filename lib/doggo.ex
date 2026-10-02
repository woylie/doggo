defmodule Doggo do
  @moduledoc """
  This module only contains miscellaneous functions.

  The components are defined in `Doggo.Components`.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc false
  def slide_label(n), do: "Slide #{n}"

  @doc false
  defmacro diagnostic(do: block) do
    if Application.compile_env(__CALLER__, :doggo, :diagnostics, false) do
      block
    end
  end

  @doc false
  defmacro build(key) do
    case Module.get_attribute(__CALLER__.module, :__dog_render__) do
      %{^key => expression} -> expression
      _ -> __CALLER__.module |> fetch_build!(key) |> Macro.escape()
    end
  end

  attr :content, :any, required: true
  attr :modifiers, :list, required: true
  attr :label, :string, required: true

  @doc false
  def control_content(%{content: nil} = assigns) do
    ~H"<span>{@label}</span>"
  end

  def control_content(assigns) do
    ~H"{@content.(Map.new(@modifiers))}"
  end

  @doc false
  defmacro build(key, suffix) do
    "#{fetch_build!(__CALLER__.module, key)}#{suffix}"
  end

  defp fetch_build!(module, key) do
    module
    |> Module.get_attribute(:__dog_build__)
    |> Doggo.Template.fetch!(key)
  end

  @doc false
  def capture_name(fun) do
    {:module, module} = Function.info(fun, :module)
    {:name, name} = Function.info(fun, :name)
    {module, name}
  end

  @doc false
  def assign_derived(%{__changed__: changed} = assigns, derived, inputs)
      when is_map(changed) do
    if Enum.any?(inputs, &Map.has_key?(changed, &1)) do
      assign(assigns, derived)
    else
      Enum.into(derived, assigns)
    end
  end

  def assign_derived(assigns, derived, _inputs), do: assign(assigns, derived)

  @doc false
  def attr_default(assigns, name, fun) do
    if Map.has_key?(assigns, name),
      do: assigns,
      else: Map.put(assigns, name, fun.())
  end

  @doc false
  def slot_default(
        %{data_attrs: %{data: modifiers}} = assigns,
        name,
        fun,
        attrs
      ) do
    case assigns do
      %{^name => []} ->
        entry =
          Map.merge(attrs.(), %{
            __slot__: name,
            inner_block: fn _changed, _arg -> fun.(Map.new(modifiers)) end
          })

        assign_derived(assigns, [{name, [entry]}], Keyword.keys(modifiers))

      _ ->
        assigns
    end
  end

  @doc false
  @deprecated "Use Doggo.JS.hide_modal/2 instead."
  defdelegate hide_modal(js \\ %JS{}, id), to: Doggo.JS

  @doc false
  @deprecated "Use Doggo.JS.show_modal/2 instead."
  defdelegate show_modal(js \\ %JS{}, id), to: Doggo.JS

  @doc false
  @deprecated "Use Doggo.JS.show_tab/3 instead."
  defdelegate show_tab(js \\ %JS{}, id, index), to: Doggo.JS

  ## Modifier classes

  @doc """
  Returns all component classes and data attributes used in the given components
  module.

  This includes the base classes, nested classes (based on the base class)
  and modifier classes.

  ## Usage

      safelist(MyAppWeb.CoreComponents)
      #=> ["button", "data-size", "data-variant"]
  """
  @doc since: "0.13.0"
  @spec safelist(module) :: [String.t()]
  def safelist(module) when is_atom(module) do
    components = module.__dog_components__()
    base_classes = Enum.map(components, &get_base_class/1)
    data_attrs = Enum.flat_map(components, &data_attrs/1)
    modifier_data_attrs = Enum.flat_map(components, &modifier_data_attrs/1)
    nested_classes = Enum.flat_map(components, &get_nested_classes/1)

    (base_classes ++ data_attrs ++ modifier_data_attrs ++ nested_classes)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp get_base_class({_, info}) do
    Keyword.get(info, :base_class)
  end

  defp data_attrs({_, info}) do
    Keyword.get(info, :data_attrs, [])
  end

  defp modifier_data_attrs({_, info}) do
    info
    |> Keyword.fetch!(:modifiers)
    |> Enum.map(fn {name, _} -> "data-#{name}" end)
  end

  defp get_nested_classes({_, info}) do
    base_class = Keyword.get(info, :base_class)
    component_module = info |> Keyword.fetch!(:component) |> component_module()
    component_module.nested_classes(base_class)
  end

  defp component_module(name) when is_atom(name) do
    module_name = name |> Atom.to_string() |> Macro.camelize()
    Module.safe_concat([Doggo.Components, module_name])
  end

  @doc false
  def ensure_own_attributes!(assigns, own_attributes, component) do
    rest = Map.get(assigns, :rest, %{})

    for {name, instead} <- own_attributes, Map.has_key?(rest, name) do
      raise ArgumentError, """
      #{name} is set by #{component}

      The component renders its own #{name} attribute. An attribute value passed
      directly is ignored by the browser.#{use_instead(instead)}

      Got:

          #{name}=#{inspect(rest[name])}
      """
    end

    :ok
  end

  defp use_instead(nil), do: ""
  defp use_instead(attr), do: " Use the #{attr} attribute instead."

  @doc false
  def ensure_label!(
        %{label: label, labelledby: labelledby},
        component,
        example_label
      ) do
    if named?(label) != named?(labelledby) do
      :ok
    else
      raise Doggo.InvalidLabelError,
        component: component,
        example_label: example_label
    end
  end

  @doc false
  def ensure_name!(name, component, attr) do
    if named?(name) do
      :ok
    else
      raise ArgumentError, """
      blank #{attr} for #{component}

      The #{attr} is the accessible name. Set it to a text that describes the
      element, and make sure that it is translated.

          #{attr}: #{inspect(name)}
      """
    end
  end

  @doc false
  def class_attr(nil), do: []
  def class_attr(class), do: [class: class]

  @doc false
  def ensure_optional_name!(nil, _component, _attr), do: :ok

  def ensure_optional_name!(name, component, attr) do
    ensure_name!(name, component, attr)
  end

  @doc false
  def named?(s) when is_binary(s), do: String.trim(s) != ""
  def named?(nil), do: false
  def named?(_), do: true
end
