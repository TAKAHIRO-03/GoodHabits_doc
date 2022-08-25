import { defineConfig } from "cypress";

export default defineConfig({
  video: false,
  screenshotsFolder: "/results/screenshots",
  videosFolder: "/results/videos",
  e2e: {
    baseUrl: "http://host.docker.internal:8888",
    supportFile: false,
  },
});
