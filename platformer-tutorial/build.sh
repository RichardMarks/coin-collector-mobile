#!/bin/sh

mkdir -p dist
nim c -d:packed ./src/main
mv ./src/main ./dist/platformer
