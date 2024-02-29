import { defineConfig } from 'vite'
import rails from 'vite-plugin-rails'

export default defineConfig({
  plugins: [
    rails(),
  ],
  // GBL Admin: Import assets from arbitrary paths.
  resolve: {
    alias: {
      '@gbl_admin/': `${process.env.GBL_ADMIN_ASSETS_PATH}/`,
    },
  },
  server: {
    fs: {
      allow: [process.env.GBL_ADMIN_ASSETS_PATH!],
    },
  },
})
