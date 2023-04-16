FROM mcr.microsoft.com/dotnet/sdk:6.0 as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      jq \
      curl && \
  mkdir -p /workspace/src /workspace/publish && \
  VERSION="$(curl -s https://api.github.com/repos/icsharpcode/ilspy/tags | \
    jq -r '[ .[] | select(.name | test("^(?!.*preview)(?!.*rc).*$")) | .name ] | first')" && \
  git config --global advice.detachedHead false && \
  git clone -b "$VERSION" https://github.com/icsharpcode/ilspy.git /workspace/src && \
  dotnet publish /workspace/src/ICSharpCode.Decompiler.Console/ICSharpCode.Decompiler.Console.csproj \
    --configuration Release \
    --output /workspace/publish/ \
    --nologo \
    --framework net6.0 \
    --runtime linux-musl-x64 \
    --self-contained \
    --verbosity quiet \
    --property:PublishSingleFile=true \
    --property:PublishTrimmed=true \
    --property:PublishReadyToRun=true \
    --property:PackAsTool=false \
    --property:DebugType=none \
    --property:DebugSymbols=false

FROM alpine:latest as final

LABEL org.opencontainers.image.source = 'https://github.com/jessenich/docker-ilspycmd'

RUN apk add -u --no-cache \
  libgcc \
  libstdc++

COPY --from=build /workspace/publish/ilspycmd /usr/local/bin/ilspycmd

VOLUME [ "/data/in" ]
VOLUME [ "/data/out" ]

ENTRYPOINT [ "/usr/local/bin/ilspycmd" ]
CMD [ "--help" ]
