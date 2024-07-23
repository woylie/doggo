defmodule Doggo.Storybook.FieldGroup do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:field]

  def template do
    """
    <Phoenix.Component.form for={%{}} as={:story} :let={f}>
      <.psb-variation />
    </Phoenix.Component.form>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]
    field_fun = dependent_components[:field]

    if field_fun do
      [
        """
        <.#{field_fun} type="text" field={f[:given_name]} label="Given name" />
        <.#{field_fun} type="text" field={f[:family_name]} label="Family name" />
        """
      ]
    else
      [
        """
        <p>Please compile the <code>field</code> component for a complete preview.</p>
        """
      ]
    end
  end
end
