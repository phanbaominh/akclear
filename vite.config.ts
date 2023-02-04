import { defineConfig } from "vite";
import { resolve } from "path";
import RubyPlugin from "vite-plugin-ruby";

export default defineConfig({
  plugins: [RubyPlugin()],
  resolve: {
    alias: {
      "@components": resolve(__dirname, "app/components"),
    },
  },
});
