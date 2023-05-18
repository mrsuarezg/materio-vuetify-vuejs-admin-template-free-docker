#!/bin/sh
# npm / yarn install and run watch
export NODE_ENV=development
echo 'running yarn install and watch for changes'
yarn install && yarn run dev