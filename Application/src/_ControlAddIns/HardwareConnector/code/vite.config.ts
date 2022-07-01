import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [svelte()],
    build: {
        rollupOptions: {
            output: {
                entryFileNames: `assets/bundle.js`,
                assetFileNames: `assets/bundle.[ext]`,
            },
        },
    },
})
