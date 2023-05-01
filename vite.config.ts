import { defineConfig } from "vite";
import { resolve } from "path";
import ViteRails from "vite-plugin-rails";

export default defineConfig({
  plugins: [ViteRails()],
  resolve: {
    alias: {
      "@components": resolve(__dirname, "app/components"),
    },
  },
});
