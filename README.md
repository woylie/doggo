# Doggo

[![Hex](https://img.shields.io/hexpm/v/doggo)](https://hex.pm/packages/doggo)

<img src="https://github.com/woylie/doggo/raw/main/doggo.png" alt="Illustration of a happy Shiba Inu dog wearing a traditional Japanese kimono. The dog is centered within a circular frame, adorned with decorative patterns that include waves and stripes, indicative of a Japanese aesthetic. The Shiba Inu is smiling with its tongue out, suggesting a cheerful and playful demeanor. The kimono features bold red and white accents, complementing the dog's tan and white fur." width="200"/>

Collection of unstyled Phoenix components with semantic CSS classes.

## Installation

The package can be installed by adding `doggo` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:doggo, "~> 0.1.1"}
  ]
end
```

### Gettext

To allow Doggo to translate certain strings such as form field errors with
Gettext, set your Gettext module in `config/config.exs`:

    config :doggo, gettext: MyApp.Gettext

### Storybook

The library is equipped with story modules for
[Phoenix Storybook](https://hex.pm/packages/phoenix_storybook). After you
followed the installation instructions of Phoenix Storybook, you can configure a
storybook module for Doggo in your application as follows:

```elixir
defmodule MyAppWeb.Storybook.Doggo do
  use PhoenixStorybook,
    otp_app: :my_app_web,
    content_path: Path.join(:code.priv_dir(:doggo), "/storybook"),
    title: "Doggo Storybook",
    css_path: "/assets/storybook.css",
    js_path: "/assets/storybook.js",
    sandbox_class: "my-app-web"
end
```

The important option here is `content_path`, which points to the storybook
directory in the `priv` folder of Doggo. Adjust the rest of the option to the
needs of your application.

In your router, add the Doggo storybook as a second storybook and change the
path of your application storybook to avoid path conflicts.

```elixir
scope "/", MyAppWeb do
  pipe_through :browser

  live_storybook("/storybook/app", backend_module: MyAppWeb.Storybook)

  live_storybook("/storybook/doggo",
    backend_module: MyAppWeb.Storybook.Doggo,
    session_name: :live_storybook_doggo,
    pipeline: false
  )
end
```

## Design decisions

- Favor semantic HTML elements over CSS classes for structure and clarity.
- Adhere to accessibility guidelines with appropriate ARIA attributes and roles.
- Utilize semantic HTML and ARIA attributes for style bindings to states, rather
  than relying on CSS classes.
- Where state or variations can not be expressed semantically, use modifier
  classes named `.is-*` or `.has-*`.
- Provide a base CSS class for each component to support unstyled or
  alternatively styled variations of the same HTML elements.
- The library is designed without default styles and does not prefer any
  particular CSS framework.

## Status

The library is actively developed. Being in its early stages, the library may
still undergo significant changes, potentially leading to breaking changes.
