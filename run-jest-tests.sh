#!/usr/bin/env bash
set -e
set -x
shopt -s globstar # to expand '**' into nested directories

for f in ./src/**/*.test.ts; do
    #NODE_OPTIONS=--experimental-vm-modules npx jest $f;
    NODE_OPTIONS=--experimental-vm-modules  NO_INSIGHT=true clinic flame -- node ./node_modules/.bin/jest $f
    NODE_OPTIONS=--experimental-vm-modules  NO_INSIGHT=true clinic doctor -- node ./node_modules/.bin/jest $f
done
