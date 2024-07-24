import StyleDictionary from "style-dictionary";
import { fileHeader, formattedVariables } from "style-dictionary/utils";

/*
Set themes here. The SCSS code uses the light theme to define the accessor
functions. Token files for a specific theme should be named `*.{theme}.json` or
`*.{theme}.js`. Files without the theme in the name are included in all themes.

When you add a theme, you will also need to add a theme file to `src/css/themes`
and use it in `src/css/themes/_index.scss`.
*/
const themes = ["light", "dark"];

const isInternal = (token) => {
  return token.attributes.category == "internal";
};

const isBaseColor = (token) => {
  return (
    token.attributes.category === "color" && token.attributes.type === "base"
  );
};

StyleDictionary.registerFilter({
  name: "noBaseColors",
  filter: (token) => {
    return !isBaseColor(token);
  },
});

StyleDictionary.registerFilter({
  name: "noInternals",
  filter: (token) => {
    return !isInternal(token);
  },
});

StyleDictionary.registerFormat({
  name: "scss/custom-properties",
  format: async function ({ dictionary, file }) {
    return (
      (await fileHeader({ file })) +
      dictionary.allTokens
        .map((prop) => `$${prop.name}: --${prop.name};`)
        .join("\n")
    );
  },
});

StyleDictionary.registerFormat({
  name: "scss/mixin",
  format: async function ({ dictionary, file, options = {} }) {
    const {
      outputReferences,
      themeable = true,
      formatting,
      usesDtcg,
    } = options;
    return (
      (await fileHeader({ file })) +
      `@mixin tokens {\n` +
      formattedVariables({
        format: "css",
        dictionary,
        outputReferences,
        themeable,
        formatting,
        usesDtcg,
      }) +
      `\n}\n`
    );
  },
});

// Platforms that are built for each theme.
const platforms = (theme = "") => {
  if (theme != "") {
    theme = "." + theme;
  }

  return {
    scss: {
      transformGroup: "scss",
      buildPath: "build/tokens/scss/",
      files: [
        {
          destination: `_mixin${theme}.scss`,
          filter: (token) => {
            return !isBaseColor(token) && !isInternal(token);
          },
          format: "scss/mixin",
        },
      ],
    },
    css: {
      transformGroup: "css",
      buildPath: "build/tokens/css/",
      files: [
        {
          destination: `tokens${theme}.css`,
          filter: (token) => {
            return !isBaseColor(token) && !isInternal(token);
          },
          format: "css/variables",
        },
      ],
    },
    json: {
      transformGroup: "js",
      buildPath: "build/tokens/json/",
      files: [
        {
          destination: `tokens${theme}.json`,
          format: "json",
        },
      ],
    },
  };
};

// Platforms that are only built once for all themes.
const themeIndependentPlatforms = {
  scss: {
    transformGroup: "scss",
    buildPath: "build/tokens/scss/",
    files: [
      {
        destination: `_variables.scss`,
        filter: (token) => {
          return !isBaseColor(token) && !isInternal(token);
        },
        format: "scss/custom-properties",
      },
      {
        destination: `_tokens.scss`,
        filter: "noBaseColors",
        format: "scss/map-deep",
        options: {
          formatting: {
            header:
              "/**\n * This output contains a map that is used to retrieve token names. Do not use\n * the tokens defined in this file directly.\n *\n",
          },
        },
      },
    ],
  },
};

await Promise.all(
  themes.map((theme) => {
    const sd = new StyleDictionary({
      include: [`tokens/**/!(*.${themes.join(`|*.`)}).{json,mjs}`],
      source: [`tokens/**/*.${theme}.{json,mjs}`],
      platforms: platforms(theme),
    });

    return sd.buildAllPlatforms();
  }),
);

const sd = new StyleDictionary({
  include: [`tokens/**/!(*.${themes.join(`|*.`)}).{json,mjs}`],
  source: [`tokens/**/*.${themes[0]}.{json,mjs}`],
  platforms: themeIndependentPlatforms,
});

sd.buildAllPlatforms();
