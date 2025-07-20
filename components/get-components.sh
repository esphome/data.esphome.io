#!/usr/bin/env bash

esphome_dir=$1

pushd $esphome_dir >/dev/null

version=$(grep '^__version__ ' esphome/const.py | sed 's/.*"\([^"]*\)"/\1/')

components=$(find esphome/components -maxdepth 1 -type d -not -path esphome/components | \
  sed 's|esphome/components/||' | \
  jq -Rc -s 'split("\n") | map(select(length > 0)) | sort')

# Initialize arrays for target platforms and platform components
target_platforms=()
platform_components=()

# Inspect each component's __init__.py file
for component in $(echo "$components" | jq -r '.[]'); do
  init_file="esphome/components/$component/__init__.py"
  if [[ -f "$init_file" ]]; then
    if grep -q "IS_TARGET_PLATFORM = True" "$init_file"; then
      target_platforms+=("$component")
    fi
    if grep -q "IS_PLATFORM_COMPONENT = True" "$init_file"; then
      platform_components+=("$component")
    fi
  fi
done

# Convert arrays to JSON
target_platforms_json=$(printf '%s\n' "${target_platforms[@]}" | jq -Rc -s 'split("\n") | map(select(length > 0)) | sort')
platform_components_json=$(printf '%s\n' "${platform_components[@]}" | jq -Rc -s 'split("\n") | map(select(length > 0)) | sort')

jq -n -c --arg version "$version" --argjson components "$components" --argjson target_platforms "$target_platforms_json" --argjson platform_components "$platform_components_json" '{
  "components": $components,
  "target_platforms": $target_platforms,
  "platform_components": $platform_components,
  "last_updated": now | strftime("%Y-%m-%dT%H:%M:%S%z"),
  "version": $version
}'

popd >/dev/null
