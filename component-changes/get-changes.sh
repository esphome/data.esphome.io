#!/bin/bash

esphome_dir=$1

pushd $esphome_dir >/dev/null

git fetch origin dev -q
git fetch origin release -q
git fetch origin beta -q
git switch release -q
release_version=$(grep '^__version__ ' esphome/const.py | sed 's/.*"\([^"]*\)"/\1/')
git switch dev -q
dev_version=$(grep '^__version__ ' esphome/const.py | sed 's/.*"\([^"]*\)"/\1/')
git switch beta -q
beta_version=$(grep '^__version__ ' esphome/const.py | sed 's/.*"\([^"]*\)"/\1/')

dev_changed=$(git diff origin/dev origin/release --name-only esphome/components | sed "s/^esphome\/components\/\([a-z0-9_]*\)\/.*$/\1/" | sort -u | jq -R -s -c 'split("\n")[:-1]')
beta_changed=$(git diff origin/beta origin/release --name-only esphome/components | sed "s/^esphome\/components\/\([a-z0-9_]*\)\/.*$/\1/" | sort -u | jq -R -s -c 'split("\n")[:-1]')

jq -n -c --arg release_version "$release_version" --arg beta_version "$beta_version" --arg dev_version "$dev_version" --argjson dev_changed "$dev_changed" --argjson beta_changed "$beta_changed" '{
  "changed_components": {
    "dev": $dev_changed,
    "beta": $beta_changed
  },
  "last_updated": now | strftime("%Y-%m-%dT%H:%M:%S%z"),
  "release_version": $release_version,
  "beta_version": $beta_version,
  "dev_version": $dev_version
}'

popd >/dev/null
