#!/bin/bash

esphome_dir=$1

pushd $esphome_dir >/dev/null

version=$(grep '^__version__ ' esphome/const.py | sed 's/.*"\([^"]*\)"/\1/')
automations=$(script/extract_automations.py)

jq -n -c --arg version "$version" --argjson automations "$automations" '{
  "automations": $automations,
  "last_updated": now | strftime("%Y-%m-%dT%H:%M:%S%z"),
  "version": $version
}'

popd >/dev/null
