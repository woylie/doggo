defmodule Doggo.Storybook.AlertDialog do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <div>
      <button phx-click={Doggo.show_modal(":variation_id")}>Open alert dialog</button>
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        note:
          "An alert dialog is not dismissable by default, so it renders " <>
            "`closedby=\"none\"` and no close button. Neither `Esc` nor a " <>
            "click outside closes it, which is the point: the answer has to " <>
            "come from the footer.",
        attributes: %{id: "dog-alert-default"},
        slots: slots("alert-dialog-single-default", opts)
      },
      %Variation{
        id: :dismissable,
        note:
          "`dismissable` adds the close button and `closedby=\"any\"`, so " <>
            "`Esc` and a click outside close it as well. Use it only when " <>
            "dismissing the dialog is itself a valid answer.",
        attributes: %{id: "dog-alert-dismissable", dismissable: true},
        slots: slots("alert-dialog-single-dismissable", opts)
      },
      %Variation{
        id: :without_javascript,
        note:
          "The opener is a plain button with `command` and `commandfor`, " <>
            "which is the Invoker Commands API: HTML attributes and no " <>
            "JavaScript. The hook acts on them where the browser does not.",
        template: command_template(),
        attributes: %{id: "dog-alert-declarative"},
        slots: slots("alert-dialog-single-without-javascript", opts)
      }
    ]
  end

  defp command_template do
    """
    <div>
      <button command="show-modal" commandfor=":variation_id">Open alert dialog</button>
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
      slots: slots("alert-dialog-#{name}-dog-mod-var-#{name}-#{value}", opts)
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
      <:title>End Training Session Early?</:title>
      """,
      """
      <p>
        Are you sure you want to end the current training session with Bella?
        She's making great progress today!
      </p>
      """,
      """
      <:footer>
        <#{tag_name} phx-click={JS.exec("data-cancel", to: "##{id}")}>
          Yes, end session
        </#{tag_name}>
        <#{tag_name} phx-click={JS.exec("data-cancel", to: "##{id}")}>
          No, continue training
        </#{tag_name}>
      </:footer>
      """
    ]
  end
end
