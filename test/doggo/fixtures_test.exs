defmodule Doggo.FixturesTest do
  @moduledoc """
  Keeps the markup fixtures the JavaScript hook tests load in step with the
  components.

  Run with `UPDATE_FIXTURES=1 mix test` after changing the markup of a
  component that ships a hook.
  """

  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]

  alias Doggo.HookComponents

  @fixture_dir Path.expand("../../assets/test/fixtures", __DIR__)

  test "tabs fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.tabs id="tabs" label="Dog Breeds">
        <:panel label="Golden Retriever">Friendly.</:panel>
        <:panel label="Siberian Husky">Energetic.</:panel>
        <:panel label="Dachshund">Playful.</:panel>
      </HookComponents.tabs>
      """,
      "tabs.html"
    )
  end

  test "carousel fixture matches the rendered component" do
    assigns = %{}

    assert_fixture(
      ~H"""
      <HookComponents.carousel id="carousel" label="Dog Fashion Show" pagination>
        <:pause label="Pause" resume_label="Resume">Pause</:pause>
        <:previous label="Previous slide">Previous</:previous>
        <:next label="Next slide">Next</:next>
        <:item label="1 of 3">Slide 1</:item>
        <:item label="2 of 3">Slide 2</:item>
        <:item label="3 of 3">Slide 3</:item>
      </HookComponents.carousel>
      """,
      "carousel.html"
    )
  end

  defp assert_fixture(rendered, name) do
    html = rendered_to_string(rendered)
    path = Path.join(@fixture_dir, name)

    if System.get_env("UPDATE_FIXTURES") do
      File.mkdir_p!(@fixture_dir)
      File.write!(path, html)
    end

    assert File.exists?(path), """
    The fixture #{name} does not exist.

    Create it by running the suite with UPDATE_FIXTURES set:

        UPDATE_FIXTURES=1 mix test
    """

    assert File.read!(path) == html, """
    The fixture #{name} is out of date, so the JavaScript hook tests are running
    against markup this component no longer emits.

    Update it and check whether the hook still works:

        UPDATE_FIXTURES=1 mix test
    """
  end
end
