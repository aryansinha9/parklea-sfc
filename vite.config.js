import { defineConfig } from 'vite';
import { resolve } from 'path';
import fs from 'fs';

const htmlFiles = fs.readdirSync('./parklea-site')
  .filter(file => file.endsWith('.html') && file !== 'template.html' && file !== 'Parkly SFC.html');

const input = {};
htmlFiles.forEach(file => {
  const name = file.replace('.html', '');
  input[name] = resolve(__dirname, 'parklea-site', file);
});

export default defineConfig({
  root: './parklea-site',
  server: { port: 3000, open: true },
  build: {
    outDir: '../dist',
    emptyOutDir: true,
    rollupOptions: {
      input
    }
  },
});
