const { copySync, removeSync } = require('fs-extra')
const mix = require('laravel-mix')

const path = require('path')

const { join, resolve } = path
require('laravel-mix-versionhash')
require('vuetifyjs-mix-extension')

/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel applications. By default, we are compiling the CSS
 | file for the application as well as bundling up all the JS files.
 |
 */

mix.js('resources/js/app.js', 'public/dist/js')
  .vuetify('vuetify-loader')
  .vue()
  .sass('resources/sass/styles/variables.scss', 'public/dist/css')
  .copy('resources/js/src/assets/images', 'public/images', false)
  .disableNotifications()

if (mix.inProduction()) {
  mix.versionHash()
} else {
  mix.sourceMaps()
}

mix.webpackConfig({
  resolve: {
    extensions: ['.js', '.json', '.vue'],
    alias: {
      '@resources': path.resolve(__dirname, 'resources/'),
      '@': path.resolve(__dirname, 'resources/js/src/')
    }
  },
  output: {
    chunkFilename: 'dist/js/chunks/[name].[chunkhash].js',
    path: resolve(__dirname, mix.inProduction() ? './public/build' : './public')
  },
  plugins: []
})

mix.then(() => {
  if (mix.inProduction()) {
    process.nextTick(() => publishAssets())
  }
})

function publishAssets () {
  const publicDir = resolve(__dirname, './public')
  removeSync(join(publicDir, 'dist'))
  copySync(join(publicDir, 'build', 'dist'), join(publicDir, 'dist'))
  removeSync(join(publicDir, 'build'))
}
