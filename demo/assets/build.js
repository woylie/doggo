import * as esbuild from "esbuild";

import postcss from "postcss";
import autoprefixer from "autoprefixer";
import { sassPlugin } from "esbuild-sass-plugin";

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const production = args.includes("--production");

const postCssPlugins = [autoprefixer];

const plugins = [
  sassPlugin({
    loadPaths: ["../.."],
    async transform(source, resolveDir) {
      const { css } = await postcss(postCssPlugins).process(source, {
        from: undefined,
      });
      return css;
    },
  }),
];

// Define esbuild options
let opts = {
  entryPoints: [
    { in: "js/app.js", out: "app" },
    { in: "js/storybook.js", out: "storybook" },
    { in: "css/storybook_theme.css", out: "storybook_theme" },
  ],
  bundle: true,
  logLevel: "info",
  target: ["es2017", "chrome121", "edge121", "firefox123", "safari17.4"],
  outdir: "../priv/static/assets",
  plugins: plugins,
};

if (production) {
  opts = {
    ...opts,
    minify: true,
  };
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };
  esbuild
    .context(opts)
    .then((ctx) => {
      ctx.watch();
    })
    .catch((_error) => {
      process.exit(1);
    });
} else {
  esbuild.build(opts);
}
