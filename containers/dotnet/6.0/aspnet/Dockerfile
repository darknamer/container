ARG REPO=unnamed22090/dotnet

# Installer image
FROM unnamed22090/ubuntu:focal as installer

# Retrieve ASP.NET Core
RUN aspnetcore_version=6.0.8 \
    && curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$aspnetcore_version/aspnetcore-runtime-$aspnetcore_version-linux-x64.tar.gz \
    && aspnetcore_sha512='b74676ca0d2f47a95533739fd36977bb1552890a81820ee51b29b3d6514398f0952362417bbb31fad4bdf031803cb3e8d2aaf065dfb154a78a1b471a536d4abd' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && tar -oxzf aspnetcore.tar.gz ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz


# ASP.NET Core image
FROM $REPO:runtime-6.0

ENV \
    # ASP.NET Core version
    ASPNET_VERSION=6.0.8 \
    # Set the default console formatter to JSON
    Logging__Console__FormatterName=Json

COPY --from=installer ["/shared/Microsoft.AspNetCore.App", "/usr/share/dotnet/shared/Microsoft.AspNetCore.App"]