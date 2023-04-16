#!/usr/bin/env bash

docker buildx build \
  -t ghcr.io/jessenich/ilspycmd:7.2.1 \
  --load \
  .
