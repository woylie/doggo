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
  Returns the 'Keyboard' section of the documentation.

  States the keys the component handles. Only implemented by components that
  handle any. Missing interaction belongs in the `maturity_note` instead.

  Used for both the component builder macro and the compiled component.
  """
  @callback keyboard() :: String.t()

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

  Takes the `extra` options as an argument.
  """
  @callback attrs_and_slots(opts :: keyword) :: Macro.t()

  @doc """
  Returns a quoted block with code that evaluates compile-time options for the
  component.
  """
  @callback init_block(opts :: Keyword.t(), extra :: Keyword.t()) :: Macro.t()

  @doc """
  Returns the quoted HEEx template that the build compiles in the module that
  builds the component.
  """
  @callback template(opts :: keyword) :: Macro.t()

  @doc """
  Returns an example label for the error raised when no label is given.

  Implemented by components that need `label` or `labelledby`. The check is
  generated into the component function, so that the error names the component
  as the caller built it.
  """
  @callback example_label() :: String.t()

  @doc """
  Returns the attributes that the component sets explicitly and that can
  also set via global attributes.

  The value is the attribute that can be used instead of the global attribute,
  or `nil`.

  If diagnostics are enabled, passing these attributes as global attributes
  raises an error to warn that these attributes are ignored by the browser.
  """
  @callback own_attributes() :: keyword(atom | nil)

  @doc """
  Returns the components this component depends on.
  """
  @callback callees() :: keyword(atom)

  @optional_callbacks builder_doc: 0,
                      callees: 0,
                      css_path: 0,
                      example_label: 0,
                      keyboard: 0,
                      own_attributes: 0
end
