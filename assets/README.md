# @woylie/doggo

JavaScript hooks for [Doggo](https://github.com/woylie/doggo), a headless
component library for Phoenix LiveView.

## Installation

Install the package with your package manager:

```bash
npm install @woylie/doggo
```

The npm package and the Hex package share a version number. Pin the same
version for both packages. A version mismatch can lead to issues.

These modules also ship inside the Hex package. If your JavaScript is built
alongside your Elixir application, you can skip npm and point `package.json` at
`link:../deps/doggo/assets` instead.

Register the hooks for the components you build:

```js
import { Accordion, Tabs } from "@woylie/doggo";

const hooks = {
  "Doggo.Accordion": Accordion,
  "Doggo.Tabs": Tabs,
};
```

The keys are the names the components render in `phx-hook`, so they have to
match exactly. See the [documentation](https://hexdocs.pm/doggo) for a list of
all hooks.
