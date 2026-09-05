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
        note:
          "`Doggo.show_modal/1` opens the dialog, which works on every " <>
            "browser and needs the hook. The close button in the footer uses " <>
            "`JS.exec(\"data-cancel\")`.",
        attributes: %{id: "dog-modal-default"},
        slots: slots("modal-single-default", opts)
      },
      %Variation{
        id: :without_javascript,
        note:
          "The opener is a plain button with `command` and `commandfor`, " <>
            "which is the Invoker Commands API: HTML attributes and no " <>
            "JavaScript. The hook acts on them where the browser does not.",
        template: command_template(),
        attributes: %{id: "dog-modal-declarative"},
        slots: slots("modal-single-without-javascript", opts)
      },
      %Variation{
        id: :not_dismissable,
        note:
          "`dismissable={false}` renders `closedby=\"none\"` and no close " <>
            "button, so neither `Esc` nor a click outside closes it. The " <>
            "control in the footer is the only way out.",
        attributes: %{id: "dog-modal-not-dismissable", dismissable: false},
        slots: slots("modal-single-not-dismissable", opts)
      }
    ]
  end

  defp command_template do
    """
    <div>
      <button command="show-modal" commandfor=":variation_id">Open modal</button>
      <.psb-variation/>
    </div>
    """
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
