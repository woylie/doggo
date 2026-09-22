defmodule DemoWeb.Storybook do
  @moduledoc false

  use PhoenixStorybook,
    otp_app: :demo,
    content_path: Path.expand("../../storybook", __DIR__),
    # assets path are remote path, not local file-system paths
    css_path: "/assets/app.css",
    js_path: "/assets/storybook.js",
    theme_path: "/assets/storybook_theme.css",
    sandbox_class: "demo-web",
    title: "Doggo Storybook #{Mix.Project.config()[:version]}",
    color_mode: true,
    color_mode_sandbox_dark_class: "theme-dark"
end
