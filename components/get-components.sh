#!/usr/bin/env bash

esphome_dir=$1

pushd $esphome_dir >/dev/null

version=$(grep '^__version__ ' esphome/const.py | sed 's/.*"\([^"]*\)"/\1/')

components=$(find esphome/components -maxdepth 1 -type d -not -path esphome/components | \
  sed 's|esphome/components/||' | \
  jq -Rc -s 'split("\n") | map(select(length > 0)) | sort')

jq -n -c --arg version "$version" --argjson components "$components" '{
  "components": $components,
  "last_updated": now | strftime("%Y-%m-%dT%H:%M:%S%z"),
  "version": $version
}'

popd >/dev/null
