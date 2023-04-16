#!/usr/bin/env bash

# shellcheck disable=SC2046,SC2086

__main() {
  DLL=$(realpath "./$1")
  PDB=${1//.dll/.pdb}
  OUT=$2

  if [[ -f $PDB ]]; then local -r USE_PDB=true; fi

  docker run \
    --volume "$DLL:/data/in/$(basename $DLL)" \
    ${USE_PDB:+--volume $PDB:/data/in/$(basename $PDB)} \
    --volume "$OUT:/data/out" \
    --rm \
    ghcr.io/jessenich/ilspycmd:7.2.1 \
    --outputdir "/data/out" \
    ${USE_PDB:+--use-varnames-from-pdb} \
    ${USE_PDB:+--generate-pdb} \
    --project \
    --no-dead-code \
    --no-dead-stores \
    --dump-package \
    /data/in/$(basename $DLL)
}

__main "$@"
