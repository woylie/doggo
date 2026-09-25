defmodule DemoWeb.PatchTestTreeBranch do
  @moduledoc """
  A tree branch rendered by a LiveComponent, for `DemoWeb.PatchTestLive`.
  """

  use DemoWeb, :live_component

  alias DemoWeb.CoreComponents

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :count, 0)}
  end

  @impl true
  def handle_event("bump", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <li id="tree-herding-component" role="none">
      <ul role="none">
        <CoreComponents.tree_item id="tree-herding">
          Herding
          <:items>
            <CoreComponents.tree_item>
              Collie · component tick {@count}
            </CoreComponents.tree_item>
          </:items>
        </CoreComponents.tree_item>
      </ul>
    </li>
    """
  end
end

defmodule DemoWeb.PatchTestTreeInComponent do
  @moduledoc """
  A whole tree rendered by a LiveComponent, for `DemoWeb.PatchTestLive`.
  """

  use DemoWeb, :live_component

  alias DemoWeb.CoreComponents

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :count, 0)}
  end

  @impl true
  def handle_event("bump", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <CoreComponents.tree id="test-tree-in-component" label="Tree in a component">
        <CoreComponents.tree_item id="tree-toy">
          Toy
          <:items>
            <CoreComponents.tree_item>
              Pug · component tick {@count}
            </CoreComponents.tree_item>
          </:items>
        </CoreComponents.tree_item>
      </CoreComponents.tree>
      <CoreComponents.button
        id="bump-tree-component"
        phx-click="bump"
        phx-target={@myself}
      >
        Update the component around the tree
      </CoreComponents.button>
    </div>
    """
  end
end
