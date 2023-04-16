FROM mcr.microsoft.com/dotnet/sdk:7.0 as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      jq \
      curl && \
  mkdir -p /workspace/src /workspace/publish && \
  VERSION="$(curl -fsSL 'https://api.github.com/repos/icsharpcode/ilspy/releases/latest' | jq .tag_name)" && \
  git clone -b $VERSION https://github.com/icsharpcode/ilspy.git --depth 1 /workspace/src && \
  dotnet publish /workspace/src/ICSharpCode.ILSpyCmd/ICSharpCode.ILSpyCmd.csproj \
    --configuration Release \
    --output /workspace/publish \
    --nologo \
    --runtime linux-musl-x64 \
    --self-contained \
    --property:PublishSingleFile=true \
    --property:PackAsTool=false \
    --property:DebugType=none \
    --property:DebugSymbols=false \
    --property:PublishReferencesDocumentationFiles=false

FROM mcr.microsoft.com/dotnet/runtime:7.0-alpine as final

COPY --from=build /workspace/publish/ilspycmd /usr/local/bin/ilspycmd

ENTRYPOINT [ "/usr/local/bin/ilspycmd" ]
CMD [ "--help" ]
