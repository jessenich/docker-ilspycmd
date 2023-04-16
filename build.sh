#!/usr/bin/env bash

VERSION="$(curl -s https://api.github.com/repos/icsharpcode/ilspy/tags | \
    jq -r '[ .[] | select(.name | test("^(?!.*preview)(?!.*rc).*$")) | .name ] | first')"

# Remove 'v' prefix
VERSION=${VERSION/v/};

docker buildx build \
  -t "ghcr.io/jessenich/ilspycmd:$VERSION" \
  --load \
  --file release.Dockerfile \
  .
