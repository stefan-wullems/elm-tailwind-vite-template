import { resolve } from "path";
import { defineConfig } from "vite";
import elmPlugin from "vite-plugin-elm";

export default defineConfig({
  plugins: [elmPlugin()],
  build: {
    rollupOptions: {
      input: resolve(__dirname, "./index.html")
    },
  },
});
