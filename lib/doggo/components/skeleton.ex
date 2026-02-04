defmodule Doggo.Components.Skeleton do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a skeleton loader, a placeholder for content that is in the process
    of loading.

    It mimics the layout of the actual content, providing a better user
    experience during loading phases.
    """
  end

  @impl true
  def usage do
    """
    Render one of the primitive types in isolation:

    ```heex
    <.skeleton type="text_line" />
    ```

    Combine primitives for complex layouts:

    ```heex
    <div class="card-skeleton" aria-busy="true">
      <.skeleton type="image" />
      <.skeleton type="text-line" />
      <.skeleton type="text-line" />
      <.skeleton type="text-line" />
      <.skeleton type="rectangle" />
    </div>
    ```

    To modify the primitives for your use cases, you can either configure
    additional modifiers or use CSS properties:

    ```heex
    <Doggo.skeleton type="text-line" variant="header" />
    ```

    ```heex
    <Doggo.skeleton type="image" style="--aspect-ratio: 75%;" />
    ```

    ## Aria-busy attribute

    When using skeleton loaders, apply `aria-busy="true"` to the container
    element that contains the skeleton layout. For standalone use, add the
    attribute directly to the individual skeleton loader.

    ## Async result component

    The easiest way to load data asynchronously and render a skeleton loader is
    to use LiveView's
    [async operations](`m:Phoenix.LiveView#module-async-operations`)
    and `Phoenix.Component.async_result/1`.

    Assuming you defined a card skeleton component as described above:

    ```heex
    <.async_result :let={puppy} assign={@puppy}>
      <:loading><.card_skeleton /></:loading>
      <:failed :let={_reason}>There was an error loading the puppy.</:failed>
      <!-- Card for loaded content -->
    </.async_result>
    ```
    """
  end

  @impl true
  def css_path do
    "components/_skeleton.scss"
  end

  @impl true
  def config do
    [
      type: :feedback,
      since: "0.6.0",
      maturity: :developing,
      maturity_note: """
      This component may not address all accessibility aspects.
      """,
      modifiers: [
        type: [
          values: [
            "text-line",
            "text-block",
            "image",
            "circle",
            "rectangle",
            "square"
          ],
          required: true
        ]
      ]
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={@class} {@data_attrs} {@rest}></div>
    """
  end
end
