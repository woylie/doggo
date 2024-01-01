defmodule DemoWeb.Storybook do
  use PhoenixStorybook,
    otp_app: :demo_web,
    content_path: Path.join(:code.priv_dir(:doggo), "storybook"),
    # assets path are remote path, not local file-system paths
    css_path: "/assets/app.css",
    js_path: "/assets/app.js",
    sandbox_class: "demo-web",
    title: "Doggo Storybook"
end
