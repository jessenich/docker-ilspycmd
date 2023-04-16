FROM mcr.microsoft.com/dotnet/sdk:6.0 as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      jq \
      curl && \
  mkdir -p /workspace/src /workspace/publish && \
  VERSION="$(curl -s https://api.github.com/repos/icsharpcode/ilspy/tags | \
    jq -r '[ .[] | select(.name | test("^(?!.*preview)(?!.*rc).*$")) | .name ] | first')" && \
  git clone -b $VERSION https://github.com/icsharpcode/ilspy.git --depth 1 /workspace/src && \
  dotnet publish /workspace/src/ICSharpCode.Decompiler.Console/ICSharpCode.Decompiler.Console.csproj \
    --configuration Release \
    --output /workspace/publish/ \
    --nologo \
    --framework net6.0 \
    --runtime linux-musl-x64 \
    --self-contained \
    --verbosity quiet \
    --property:PublishSingleFile=true \
    --property:PackAsTool=false \
    --property:DebugType=none \
    --property:DebugSymbols=false \
    --property:PublishReferencesDocumentationFiles=false

FROM mcr.microsoft.com/dotnet/runtime:6.0-alpine as final

COPY --from=build /workspace/publish/ilspycmd /usr/local/bin/ilspycmd

ENTRYPOINT [ "/usr/local/bin/ilspycmd" ]
CMD [ "--help" ]
