#!/usr/bin/env bash

VERSION="$(curl -fsSL 'https://api.github.com/repos/icsharpcode/ilspy/releases/latest' | jq .tag_name)"

docker buildx build \
  -t "ghcr.io/jessenich/ilspycmd:$VERSION" \
  --load \
  --file prerelease.Dockerfile \
  .
