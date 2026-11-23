defmodule DemoWeb.E2E.AxeTest do
  use DemoWeb.BrowserCase, async: true

  @storybook_dir Path.expand("../../storybook", __DIR__)

  story_paths = fn story_paths, dir, prefix ->
    dir
    |> File.ls!()
    |> Enum.sort()
    |> Enum.flat_map(fn name ->
      path = Path.join(dir, name)

      cond do
        File.dir?(path) ->
          story_paths.(story_paths, path, "#{prefix}#{name}/")

        String.ends_with?(name, ".story.exs") ->
          ["#{prefix}#{String.replace_suffix(name, ".story.exs", "")}"]

        true ->
          []
      end
    end)
  end

  # A story page renders every variation of a component at once. Landmarks
  # in a story can therefore share a page and a name.
  @known %{
    "data/accordion" => ["landmark-unique"],
    "layout/app_bar" => ["landmark-no-duplicate-banner", "landmark-unique"],
    "layout/drawer" => ["landmark-unique"],
    "layout/page_header" => ["landmark-no-duplicate-banner", "landmark-unique"],
    "media/carousel" => ["landmark-unique"],
    "feedback/callout" => ["landmark-unique"],
    "navigation/bottom_navigation" => ["landmark-unique"],
    "navigation/navbar" => ["landmark-unique"],
    "navigation/steps" => ["landmark-unique"],
    "navigation/vertical_nav" => ["landmark-unique"]
  }

  for story <- story_paths.(story_paths, @storybook_dir, "") do
    @story story
    test "reports no axe violations for #{story}", %{page: page} do
      Page.goto!(page, "/storybook/#{@story}")

      page
      |> Page.locator(".psb-sandbox")
      |> Locator.first()
      |> Locator.wait_for!()

      violations = axe_violations(page, ".psb-sandbox")

      assert violations |> Enum.map(& &1["id"]) |> Enum.sort() ==
               Map.get(@known, @story, [])
    end
  end
end
