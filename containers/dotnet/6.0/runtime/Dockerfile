ARG REPO=unnamed22090/dotnet

# Installer image
FROM unnamed22090/ubuntu:focal as installer

# Retrieve .NET
RUN dotnet_version=6.0.8 \
    && curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$dotnet_version/dotnet-runtime-$dotnet_version-linux-x64.tar.gz \
    && dotnet_sha512='c776813bf87c25766b31a3a514d124d0526086ceea514a10f104d70ba435c91a6bd3c8bf10c6662b4df2b13ffcdf385518f3418e51d05cccec6a2cf2c26099de' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /dotnet \
    && tar -oxzf dotnet.tar.gz -C /dotnet \
    && rm dotnet.tar.gz

# .NET runtime image
FROM $REPO:runtime-deps-6.0

ENV DOTNET_VERSION=6.0.8

COPY --from=installer ["/dotnet", "/usr/share/dotnet"]

RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet