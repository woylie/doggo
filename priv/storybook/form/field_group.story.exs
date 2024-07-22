defmodule Storybook.Components.FieldGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.field_group/1

  def template do
    """
    <Phoenix.Component.form for={%{}} as={:story} :let={f}>
      <.psb-variation />
    </Phoenix.Component.form>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          """
          <Doggo.input type="text" field={f[:given_name]} label="Given name" />
          <Doggo.input type="text" field={f[:family_name]} label="Family name" />
          """
        ]
      }
    ]
  end
end
