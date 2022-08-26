import { defineConfig } from "cypress";

export default defineConfig({
  video: false,
  screenshotsFolder: "/results/screenshots",
  videosFolder: "/results/videos",
  e2e: {
    baseUrl: "http://client-ctr:8888",
    supportFile: false,
  },
});
