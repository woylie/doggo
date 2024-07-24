defmodule Doggo.Components.FieldGroup do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Use the field group component to visually group multiple inputs in a form.

    This component is intended for styling purposes and does not provide semantic
    grouping. For semantic grouping of related form elements, use the `<fieldset>`
    and `<legend>` HTML elements instead.
    """
  end

  @impl true
  def usage do
    """
    Visual grouping of inputs:

    ```heex
    <.field_group>
      <.field field={@form[:given_name]} label="Given name" />
      <.field field={@form[:family_name]} label="Family name"/>
    </.field_group>
    ```

    Semantic grouping (for reference):

    ```heex
    <fieldset>
      <legend>Personal Information</legend>
      <.field field={@form[:given_name]} label="Given name" />
      <.field field={@form[:family_name]} label="Family name"/>
    </fieldset>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :form,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block, required: true
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
