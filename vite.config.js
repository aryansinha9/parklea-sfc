import { defineConfig } from 'vite';
export default defineConfig({
  root: './parklea-site',
  server: { port: 3000, open: true },
  build: { outDir: '../dist' },
});
