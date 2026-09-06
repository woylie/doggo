import { defineConfig } from "vitest/config";

export default defineConfig({
  server: { fs: { allow: [".."] } },
  test: {
    environment: "happy-dom",
    include: ["test/**/*.test.js"],
  },
});
