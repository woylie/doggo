defmodule DemoWeb.Storybook do
  @moduledoc false

  use PhoenixStorybook,
    otp_app: :demo,
    content_path: Path.expand("../../storybook", __DIR__),
    # assets path are remote path, not local file-system paths
    css_path: "/assets/app.css",
    js_path: "/assets/storybook.js",
    sandbox_class: "demo-web",
    title: "Doggo Storybook #{Mix.Project.config()[:version]}",
    color_mode: true
end
