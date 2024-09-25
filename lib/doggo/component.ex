defmodule Doggo.Component do
  @moduledoc false

  @doc """
  Returns the first part of the documentation.

  Used for both the component builder macro and the compiled component.
  """
  @callback doc() :: String.t()

  @doc """
  Returns the documentation section for the builder macro.

  This documentation is not used for the compiled component.
  """
  @callback builder_doc() :: String.t()

  @doc """
  Returns the 'Usage' section of the documentation.

  Used for both the component builder macro and the compiled component.
  """
  @callback usage() :: String.t()

  @doc """
  Returns the path to the example CSS styles.
  """
  @callback css_path() :: String.t()

  @doc """
  Returns the component configuration.
  """
  @callback config() :: keyword

  @doc """
  Returns a list of all nested classes used by the component.
  """
  @callback nested_classes(base_class :: String.t() | nil) :: [String.t()]

  @doc """
  Returns a quoted block with the attributes and slots.
  """
  @callback attrs_and_slots() :: Macro.t()

  @doc """
  Returns a quoted block with code that evaluates compile-time options for the
  component.
  """
  @callback init_block(opts :: Keyword.t(), extra :: Keyword.t()) :: Macro.t()

  @doc """
  The Phoenix component that receives the prepared class and additional
  attributes from the init block.
  """
  @callback render(assigns :: map()) :: Phoenix.LiveView.Rendered.t()

  @optional_callbacks builder_doc: 0, css_path: 0
end
