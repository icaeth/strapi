import { defineConfig, UserConfig } from 'vite';
import { merge } from 'lodash';

module.exports = (config: UserConfig): UserConfig => {
  // Important: Always return the modified config
  // console.log(config, '<<< config')

  const viteConfig: UserConfig = defineConfig({
    server: {
      fs: {
        allow: [
          '/opt/node_modules', // This is the abs path OUTSIDE the project root causing the Vite error
          '/opt/app',
        ],
      },
    },
  });

  const mergedConfig: UserConfig = merge(config, viteConfig);

  // console.log(mergedConfig, '<<< mergedConfig')
  return mergedConfig;
};
