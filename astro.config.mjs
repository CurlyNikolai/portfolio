import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import { BASE_PATH, SITE_URL } from './src/config.ts'

export default defineConfig({
  integrations: [mdx()],
  site: SITE_URL,
  base: BASE_PATH
});
