ARG REPO=unnamed22090/dotnet

# Installer image
FROM unnamed22090/ubuntu:jammy AS installer

# Retrieve .NET Runtime
RUN dotnet_version=8.0.6 \
    && curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$dotnet_version/dotnet-runtime-$dotnet_version-linux-x64.tar.gz \
    && dotnet_sha512='c0c5e93d4e68e2075c4c63336dc74246efb704ac9663411351efdefc4cc7da5a7750f44b8a23aebe959bb4308575bead443a41b2524ae03b29ac41929d27e0e0' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /dotnet \
    && tar -oxzf dotnet.tar.gz -C /dotnet \
    && rm dotnet.tar.gz


# .NET runtime image
FROM $REPO:runtime-deps-9.0

# .NET Runtime version
ENV DOTNET_VERSION=9.0.1

COPY --from=installer ["/dotnet", "/usr/share/dotnet"]

RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
