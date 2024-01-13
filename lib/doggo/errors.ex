defmodule Doggo.InvalidLabelError do
  @moduledoc false
  defexception [:component, :message]

  def exception(opts) do
    component = Keyword.fetch!(opts, :component)
    example_label = Keyword.fetch!(opts, :example_label)

    msg = """
    Invalid label attributes for carousel

    #{component} requires exactly one of 'label' or 'labelledby' set for
    accessibility. These attributes are essential for screen readers and other
    assistive technologies to provide a textual alternative for interactive
    elements.

    - If neither is set, the component is not properly accessible.
    - If both are set, it may cause confusion for assistive technologies.

    ## Examples

    With 'label' attribute (when there is no visual label):

        <#{component} label="#{example_label}" />

    With 'labelledby' attribute (to reference an existing visible label):

        <h3 id="example-label">#{example_label}</h3>
        <#{component} labelledby="example-label" />
    """

    %__MODULE__{message: msg, component: component}
  end
end
