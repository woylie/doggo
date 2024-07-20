# Doggo

[![Hex](https://img.shields.io/hexpm/v/doggo)](https://hex.pm/packages/doggo) ![CI](https://github.com/woylie/doggo/workflows/CI/badge.svg) [![Coverage Status](https://coveralls.io/repos/github/woylie/doggo/badge.svg)](https://coveralls.io/github/woylie/doggo)

<img src="https://github.com/woylie/doggo/raw/main/assets/doggo.png" alt="Illustration of a happy Shiba Inu dog wearing a traditional Japanese kimono. The dog is centered within a circular frame, adorned with decorative patterns that include waves and stripes, indicative of a Japanese aesthetic. The Shiba Inu is smiling with its tongue out, suggesting a cheerful and playful demeanor. The kimono features bold red and white accents, complementing the dog's tan and white fur." width="200"/>

Headless UI component collection for Phoenix, focused on semantics and
accessibility.

For a full list of available components, please refer to the
[documentation](https://hexdocs.pm/doggo/Doggo.html).

## Installation

The package can be installed by adding `doggo` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:doggo, "~> 0.5.0"}
  ]
end
```

## Usage

Use `Doggo.Components` in your core components module or in a separate module.
`Doggo.Components` defines macros that generate Phoenix components.

```elixir
defmodule MyAppWeb.CoreComponents do
  use Doggo.Components
  use Phoenix.Component

  alert()
  alert_dialog()

  button(
    modifiers: [
      variant: [
        values: ["primary", "secondary", "outline"],
        default: "primary"
      ],
      size: [values: ["small", "normal"], default: "normal"]
    ]
  )
end
```

Refer to the `Doggo.Components` module documentation for more information about
the options and the individual components.

### Gettext

To allow Doggo to translate certain strings such as form field errors with
Gettext, set your Gettext module in `config/config.exs`:

```elixir
config :doggo, gettext: MyApp.Gettext
```

This only affects the `input` component. If you prefer, you can pass the
gettext module as an attribute to the component instead.

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

### PurgeCSS

If you use PurgeCSS, you will need to add `deps/doggo/lib/doggo.ex` to your
PurgeCSS configuration.

Doggo also uses modifier CSS classes to alter the appearance of components. The
class names are generated dynamically, which means PurgeCSS won't be able to
find them in the source code. You can use `mix dog.modifiers` to save a
list of all modifier class names to a file:

```bash
mix dog.modifiers -o assets/modifiers.txt
```

Add the generated file to your PurgeCSS configuration as well.

## Design decisions

- Favor semantic HTML elements over CSS classes for structure and clarity.
- Adhere to accessibility guidelines with appropriate ARIA attributes and roles.
- Utilize semantic HTML and ARIA attributes for style bindings to states, rather
  than relying on CSS classes.
- Where state or variations can not be expressed semantically, use modifier
  classes named `.is-*` or `.has-*`.
- The library is designed without default styles and does not prefer any
  particular CSS framework.

## Demo app

The repository contains a demo application that renders the plain storybook.
Note that it doesn't come with any CSS, so all components will be rendered with
default browser styles.

```bash
git clone git@github.com:woylie/doggo.git
cd doggo/demo
mix setup
mix phx.server
```

The storybook can be accessed at http://localhost:4000.

## Status

The library is actively developed. Being in its early stages, the library may
still undergo significant changes, potentially leading to breaking changes.

If you miss a component, if you have trouble with an existing component, or if a
component doesn't work for you in a certain use case, please don't hesitate to
open a [Github issue](https://github.com/woylie/doggo/issues).
