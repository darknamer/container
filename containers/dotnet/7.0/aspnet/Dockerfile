ARG REPO=unnamed22090/dotnet

# Installer image
FROM unnamed22090/ubuntu:jammy AS installer

# Retrieve ASP.NET Core
RUN aspnetcore_version=7.0.7 \
    && curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$aspnetcore_version/aspnetcore-runtime-$aspnetcore_version-linux-x64.tar.gz \
    && aspnetcore_sha512='e56ee9bc458214bce461e9688e5229ba5b69046ec38a27bfdb2b5413d4b41500cca40152d182793c2768318719d97980b62ae9724de75d6d02874c25e938374d' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && tar -oxzf aspnetcore.tar.gz ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz

# ASP.NET Core image
FROM $REPO:runtime-7.0

# ASP.NET Core version
ENV ASPNET_VERSION=7.0.7

COPY --from=installer ["/shared/Microsoft.AspNetCore.App", "/usr/share/dotnet/shared/Microsoft.AspNetCore.App"]