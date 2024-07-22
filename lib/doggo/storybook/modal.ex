defmodule Doggo.Storybook.Modal do
  @moduledoc false

  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <div>
      <button phx-click={Doggo.show_modal(":variation_id")}>Open modal</button>
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{id: "dog-modal-default"},
        slots: slots("modal-single-default", opts)
      }
    ]
  end

  def modifier_variation_group_template(_name, _opts) do
    template()
  end

  def modifier_variation_base(id, name, value, opts) do
    %{
      attributes: %{id: id},
      slots: slots("modal-#{name}-dog-mod-var-#{name}-#{value}", opts)
    }
  end

  defp slots(id, opts) do
    dependent_components = opts[:dependent_components]

    tag_name =
      if function_name = dependent_components[:button] do
        ".#{function_name}"
      else
        "button"
      end

    [
      """
      <:title>Show pet</:title>
      """,
      """
      <p>My pet is called Johnny.</p>
      """,
      """
      <:footer>
        <#{tag_name} phx-click={JS.exec("data-cancel", to: "##{id}")}>
          Close
        </#{tag_name}>
      </:footer>
      """
    ]
  end
end
