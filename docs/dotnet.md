# .NET Container Documentation

Comprehensive documentation for .NET Docker containers in this repository. This guide is designed for both developers and tech leads to understand, use, and maintain .NET container images.

## 📋 Table of Contents

- [Overview](#overview)
- [Available Versions](#available-versions)
- [Container Variants](#container-variants)
- [Architecture & Layering](#architecture--layering)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Technical Details](#technical-details)
- [Best Practices](#best-practices)
- [Image Tags & Registry](#image-tags--registry)
- [Environment Variables](#environment-variables)
- [Dependencies & Tools](#dependencies--tools)
- [Multi-Stage Build Patterns](#multi-stage-build-patterns)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This repository provides production-ready .NET Docker containers for multiple .NET versions (3.1 through 10.0). All containers are based on Ubuntu and follow Microsoft's official .NET Docker image patterns with optimizations for production use.

### Key Features

- **Multi-version support**: .NET 3.1, 6.0, 7.0, 8.0, 9.0, and 10.0
- **Four variant types**: runtime-deps, runtime, aspnet, and sdk
- **Production optimized**: Minimal image sizes with essential dependencies only
- **PowerShell included**: SDK variants include PowerShell for automation
- **Security focused**: Non-root user, verified downloads with SHA512 checksums
- **Multi-registry**: Published to DockerHub and GitHub Container Registry

## 📦 Available Versions

| Version | Status  | Base OS              | Variants Available                 |
| ------- | ------- | -------------------- | ---------------------------------- |
| 3.1     | LTS     | Ubuntu 20.04 (Focal) | runtime-deps, runtime, aspnet, sdk |
| 6.0     | LTS     | Ubuntu 22.04 (Jammy) | runtime-deps, runtime, aspnet, sdk |
| 7.0     | Current | Ubuntu 22.04 (Jammy) | runtime-deps, runtime, aspnet, sdk |
| 8.0     | LTS     | Ubuntu 22.04 (Jammy) | runtime-deps, runtime, aspnet, sdk |
| 9.0     | Current | Ubuntu 24.04 (Noble) | runtime-deps, runtime, aspnet, sdk |
| 10.0    | Current | Ubuntu 24.04 (Noble) | runtime-deps, runtime, aspnet, sdk |

**Note**: LTS (Long Term Support) versions are recommended for production environments.

## 🏗️ Container Variants

### runtime-deps

**Purpose**: Minimal base layer with only .NET runtime dependencies (no .NET runtime itself)

**Use Cases**:

- Base image for custom .NET installations
- Minimal footprint when you need to install .NET manually
- Building custom runtime configurations

**Contents**:

- Ubuntu base image
- System libraries: `libc6`, `libgcc-s1`, `libicu74`, `libssl3t64`, `libstdc++6`
- CA certificates
- Timezone data
- Non-root user (`app` with UID 1654)

**Size**: ~50-80 MB

### runtime

**Purpose**: Full .NET runtime for running compiled applications

**Use Cases**:

- Running published .NET applications
- Console applications
- Production deployments (when SDK not needed)

**Contents**:

- Everything from `runtime-deps`
- Complete .NET runtime
- `dotnet` command available

**Size**: ~200-300 MB

### aspnet

**Purpose**: ASP.NET Core runtime for web applications

**Use Cases**:

- Running ASP.NET Core web applications
- Web APIs
- Production web application deployments

**Contents**:

- Everything from `runtime`
- ASP.NET Core runtime
- All ASP.NET Core shared frameworks

**Size**: ~250-350 MB

### sdk

**Purpose**: Full development environment with SDK and tools

**Use Cases**:

- Building .NET applications
- Development environments
- CI/CD build stages
- Running tests

**Contents**:

- Everything from `aspnet`
- Complete .NET SDK
- Development tools and templates
- PowerShell (global tool)
- Additional tools: `curl`, `git`, `wget`, `default-jdk`, `zip`, `unzip`

**Size**: ~800 MB - 1.2 GB

## 🏛️ Architecture & Layering

The .NET containers follow a layered architecture where each variant builds upon the previous one:

```
runtime-deps (base)
    ↓
runtime (adds .NET runtime)
    ↓
aspnet (adds ASP.NET Core)
    ↓
sdk (adds SDK + tools)
```

### Build Process

1. **runtime-deps**: Starts from Ubuntu base, installs system dependencies
2. **runtime**: Downloads and installs .NET runtime on top of runtime-deps
3. **aspnet**: Downloads and installs ASP.NET Core runtime on top of runtime
4. **sdk**: Downloads and installs .NET SDK + PowerShell on top of aspnet

### Multi-Stage Builds

All variants use multi-stage builds:

- **Installer stage**: Downloads and verifies .NET components using SHA512 checksums
- **Final stage**: Copies verified components into the final image

This ensures:

- Security: All downloads are verified
- Size optimization: Installer tools are not included in final image
- Reproducibility: SHA512 checksums ensure consistent builds

## 🚀 Quick Start

### Pull a Container

```bash
# Pull .NET SDK 10.0 (for development)
docker pull unnamed22090/dotnet:sdk-10.0

# Pull ASP.NET Core runtime 8.0 (for production)
docker pull unnamed22090/dotnet:aspnet-8.0

# Pull .NET runtime 6.0 (for console apps)
docker pull unnamed22090/dotnet:runtime-6.0
```

### Verify Installation

```bash
# Check .NET version
docker run --rm unnamed22090/dotnet:sdk-10.0 dotnet --version

# Check PowerShell (SDK variants only)
docker run --rm unnamed22090/dotnet:sdk-10.0 pwsh --version

# List installed SDKs
docker run --rm unnamed22090/dotnet:sdk-10.0 dotnet --list-sdks
```

### Run a Simple Application

```bash
# Create a simple console app
docker run -it --rm \
  -v ${PWD}:/app \
  -w /app \
  unnamed22090/dotnet:sdk-10.0 \
  dotnet new console -n MyApp
```

## 💡 Usage Examples

### Example 1: Web API Development (Multi-Stage Build)

**Recommended for**: Production applications

```dockerfile
# Build stage
FROM unnamed22090/dotnet:sdk-10.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/MyApi"
RUN dotnet build "MyApi.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish

# Runtime stage
FROM unnamed22090/dotnet:aspnet-10.0
WORKDIR /app
EXPOSE 8080

# Copy published app
COPY --from=publish /app/publish .

# Run as non-root user
USER app
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### Example 2: Console Application

```dockerfile
FROM unnamed22090/dotnet:sdk-8.0 AS build
WORKDIR /src
COPY ["ConsoleApp/ConsoleApp.csproj", "ConsoleApp/"]
RUN dotnet restore "ConsoleApp/ConsoleApp.csproj"
COPY . .
WORKDIR "/src/ConsoleApp"
RUN dotnet build "ConsoleApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ConsoleApp.csproj" -c Release -o /app/publish

FROM unnamed22090/dotnet:runtime-8.0
WORKDIR /app
COPY --from=publish /app/publish .
USER app
ENTRYPOINT ["dotnet", "ConsoleApp.dll"]
```

### Example 3: Development Container

```dockerfile
FROM unnamed22090/dotnet:sdk-10.0

# Install additional development tools
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Set up development environment
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
ENV DOTNET_WATCH_RESTART_ON_RUDE_EDIT=true

CMD ["dotnet", "watch", "run"]
```

### Example 4: Docker Compose for Development

```yaml
version: "3.8"

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    volumes:
      - ./src:/app/src
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
    command: dotnet watch run --project /app/src/MyApi/MyApi.csproj
```

### Example 5: Running Tests in CI/CD

```dockerfile
FROM unnamed22090/dotnet:sdk-10.0 AS test
WORKDIR /src

# Copy solution and project files
COPY *.sln .
COPY ["Tests/Tests.csproj", "Tests/"]
COPY ["MyApp/MyApp.csproj", "MyApp/"]

# Restore dependencies
RUN dotnet restore

# Copy source code
COPY . .

# Run tests
RUN dotnet test --no-restore --verbosity normal
```

## 🔧 Technical Details

### Base Images

- **.NET 3.1**: `unnamed22090/ubuntu:focal` (Ubuntu 20.04)
- **.NET 6.0, 7.0, 8.0**: `unnamed22090/ubuntu:jammy` (Ubuntu 22.04)
- **.NET 9.0, 10.0**: `ubuntu.azurecr.io/ubuntu:noble` (Ubuntu 24.04)

### Download Sources

All .NET components are downloaded from official Microsoft sources:

- **Runtime**: `https://builds.dotnet.microsoft.com/dotnet/Runtime/{version}/`
- **ASP.NET Core**: `https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/{version}/`
- **SDK**: `https://builds.dotnet.microsoft.com/dotnet/Sdk/{version}/`
- **PowerShell**: `https://powershellinfraartifacts-gkhedzdeaghdezhr.z01.azurefd.net/tool/{version}/`

### Security Features

1. **SHA512 Verification**: All downloads are verified using SHA512 checksums
2. **Non-root User**: Containers run as user `app` (UID 1654) by default
3. **Minimal Attack Surface**: Only essential packages installed
4. **No Certificate Generation**: `DOTNET_GENERATE_ASPNET_CERTIFICATE=false` prevents unnecessary certificate generation
5. **Verified Sources**: All downloads from official Microsoft endpoints

### File Structure

```
/usr/share/dotnet/          # .NET installation directory
  ├── dotnet                # Main dotnet executable
  ├── sdk/                  # SDK versions (SDK variants only)
  ├── shared/               # Shared frameworks
  │   ├── Microsoft.NETCore.App/
  │   └── Microsoft.AspNetCore.App/
  └── packs/                # NuGet packages cache

/usr/share/powershell/      # PowerShell installation (SDK variants only)
  └── pwsh                  # PowerShell executable

/usr/bin/
  ├── dotnet -> /usr/share/dotnet/dotnet
  └── pwsh -> /usr/share/powershell/pwsh (SDK variants only)
```

## ✅ Best Practices

### For Developers

1. **Use Multi-Stage Builds**: Always separate build and runtime stages

   ```dockerfile
   FROM unnamed22090/dotnet:sdk-10.0 AS build
   # ... build steps ...
   FROM unnamed22090/dotnet:aspnet-10.0
   # ... runtime steps ...
   ```

2. **Layer Caching**: Copy dependency files first to leverage Docker layer caching

   ```dockerfile
   COPY ["MyApp/MyApp.csproj", "MyApp/"]
   RUN dotnet restore "MyApp/MyApp.csproj"
   COPY . .
   ```

3. **Use Specific Tags**: Always pin to specific versions, avoid `latest`

   ```dockerfile
   FROM unnamed22090/dotnet:aspnet-8.0  # ✅ Good
   FROM unnamed22090/dotnet:aspnet      # ❌ Avoid
   ```

4. **Run as Non-Root**: Use the built-in `app` user or create your own

   ```dockerfile
   USER app
   ```

5. **Expose Correct Ports**: Use port 8080 for newer versions (10.0+), port 80 for older versions
   ```dockerfile
   EXPOSE 8080  # .NET 9.0, 10.0
   EXPOSE 80    # .NET 3.1-8.0
   ```

### For Tech Leads

1. **Version Selection**:

   - **Production**: Use LTS versions (3.1, 6.0, 8.0)
   - **New Projects**: Use latest LTS (8.0) or current (10.0)
   - **Legacy Support**: Maintain 3.1 for older applications

2. **Image Size Optimization**:

   - Use `runtime` or `aspnet` for production (not `sdk`)
   - Remove unnecessary files in final stage
   - Use `.dockerignore` to exclude unnecessary files

3. **Security**:

   - Regularly update base images
   - Monitor for security advisories
   - Use specific version tags (not `latest`)
   - Scan images with security tools

4. **CI/CD Integration**:

   - Use SDK variant for build stages
   - Use runtime/aspnet variants for deployment
   - Cache NuGet packages between builds
   - Run tests in separate stage

5. **Monitoring & Logging**:
   - Configure proper logging in applications
   - Use health checks
   - Monitor container resource usage

## 🏷️ Image Tags & Registry

### DockerHub

**Repository**: `unnamed22090/dotnet`

**Tag Format**: `{variant}-{version}`

**Examples**:

- `sdk-10.0`
- `aspnet-8.0`
- `runtime-6.0`
- `runtime-deps-3.1`

### GitHub Container Registry

**Repository**: `ghcr.io/unnamed22090/dotnet`

**Tag Format**: Same as DockerHub

### Pulling Images

```bash
# From DockerHub
docker pull unnamed22090/dotnet:sdk-10.0

# From GitHub Container Registry
docker pull ghcr.io/unnamed22090/dotnet:sdk-10.0
```

## 🌍 Environment Variables

### Standard .NET Variables

| Variable                      | Default       | Description                     |
| ----------------------------- | ------------- | ------------------------------- |
| `DOTNET_VERSION`              | (varies)      | .NET runtime version            |
| `ASPNET_VERSION`              | (varies)      | ASP.NET Core version            |
| `DOTNET_SDK_VERSION`          | (varies)      | .NET SDK version (SDK variants) |
| `DOTNET_RUNNING_IN_CONTAINER` | `true`        | Indicates running in container  |
| `ASPNETCORE_HTTP_PORTS`       | `8080`        | HTTP port for web apps (10.0+)  |
| `ASPNETCORE_URLS`             | `http://+:80` | URLs for web apps (3.1-8.0)     |

### Performance & Behavior

| Variable                             | Default | Description                                |
| ------------------------------------ | ------- | ------------------------------------------ |
| `DOTNET_GENERATE_ASPNET_CERTIFICATE` | `false` | Disable certificate generation             |
| `DOTNET_NOLOGO`                      | `true`  | Suppress .NET CLI welcome message          |
| `DOTNET_USE_POLLING_FILE_WATCHER`    | `true`  | Use polling for file watching (containers) |
| `NUGET_XMLDOC_MODE`                  | `skip`  | Skip XML documentation extraction          |
| `DOTNET_ROLL_FORWARD`                | `Major` | Roll forward policy (10.0+)                |

### PowerShell Variables

| Variable                          | Default  | Description                                |
| --------------------------------- | -------- | ------------------------------------------ |
| `POWERSHELL_DISTRIBUTION_CHANNEL` | (varies) | PowerShell distribution channel identifier |

## 🛠️ Dependencies & Tools

### System Dependencies (runtime-deps)

- `ca-certificates`: SSL/TLS certificate support
- `libc6`: C standard library
- `libgcc-s1`: GCC support library
- `libicu74` / `libicu66`: Internationalization components
- `libssl3t64` / `libssl1.1`: OpenSSL library
- `libstdc++6`: C++ standard library
- `tzdata`: Timezone data
- `tzdata-legacy`: Legacy timezone support (10.0+)

### Additional Tools (SDK variants)

- `curl`: HTTP client
- `git`: Version control
- `libatomic1`: Atomic operations library
- `wget`: File downloader
- `default-jdk`: Java Development Kit (for some .NET tools)
- `zip` / `unzip`: Archive utilities
- `PowerShell`: Cross-platform shell and scripting language

## 🔄 Multi-Stage Build Patterns

### Pattern 1: Standard Web API

```dockerfile
# Stage 1: Restore
FROM unnamed22090/dotnet:sdk-10.0 AS restore
WORKDIR /src
COPY *.sln .
COPY ["Api/Api.csproj", "Api/"]
RUN dotnet restore

# Stage 2: Build
FROM restore AS build
COPY . .
RUN dotnet build -c Release --no-restore

# Stage 3: Publish
FROM build AS publish
RUN dotnet publish "Api/Api.csproj" -c Release -o /app/publish --no-restore

# Stage 4: Runtime
FROM unnamed22090/dotnet:aspnet-10.0
WORKDIR /app
COPY --from=publish /app/publish .
USER app
ENTRYPOINT ["dotnet", "Api.dll"]
```

### Pattern 2: With Tests

```dockerfile
# Build and test
FROM unnamed22090/dotnet:sdk-10.0 AS test
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet build
RUN dotnet test --no-build --verbosity normal

# Publish
FROM test AS publish
RUN dotnet publish "App/App.csproj" -c Release -o /app/publish

# Runtime
FROM unnamed22090/dotnet:runtime-10.0
WORKDIR /app
COPY --from=publish /app/publish .
USER app
ENTRYPOINT ["dotnet", "App.dll"]
```

## 🐛 Troubleshooting

### Common Issues

#### Issue: "dotnet: command not found"

**Solution**: Ensure you're using `runtime`, `aspnet`, or `sdk` variant (not `runtime-deps`)

```dockerfile
# ❌ Wrong
FROM unnamed22090/dotnet:runtime-deps-10.0

# ✅ Correct
FROM unnamed22090/dotnet:runtime-10.0
```

#### Issue: "Cannot find ASP.NET Core runtime"

**Solution**: Use `aspnet` or `sdk` variant for ASP.NET Core applications

```dockerfile
# ❌ Wrong for web apps
FROM unnamed22090/dotnet:runtime-10.0

# ✅ Correct
FROM unnamed22090/dotnet:aspnet-10.0
```

#### Issue: "Permission denied" errors

**Solution**: Run as non-root user or adjust permissions

```dockerfile
USER app
# or
RUN chown -R app:app /app
```

#### Issue: Port binding fails

**Solution**: Check port configuration based on .NET version

```dockerfile
# .NET 10.0+
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080

# .NET 3.1-8.0
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
```

#### Issue: File watching doesn't work

**Solution**: Enable polling file watcher (required in containers)

```dockerfile
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
```

### Debugging Tips

1. **Check .NET Version**:

   ```bash
   docker run --rm unnamed22090/dotnet:sdk-10.0 dotnet --version
   ```

2. **List Installed Runtimes**:

   ```bash
   docker run --rm unnamed22090/dotnet:aspnet-10.0 dotnet --list-runtimes
   ```

3. **List Installed SDKs** (SDK variants only):

   ```bash
   docker run --rm unnamed22090/dotnet:sdk-10.0 dotnet --list-sdks
   ```

4. **Interactive Shell**:

   ```bash
   docker run -it --rm unnamed22090/dotnet:sdk-10.0 bash
   ```

5. **Check Environment Variables**:
   ```bash
   docker run --rm unnamed22090/dotnet:aspnet-10.0 env | grep DOTNET
   ```

## 📚 Additional Resources

- [.NET Docker Hub](https://hub.docker.com/_/microsoft-dotnet)
- [.NET Docker Samples](https://github.com/dotnet/dotnet-docker)
- [.NET Documentation](https://docs.microsoft.com/dotnet/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📝 Version History

| Version | Release Date | Base OS      | Notes                                       |
| ------- | ------------ | ------------ | ------------------------------------------- |
| 10.0    | 2024         | Ubuntu 24.04 | Latest, includes PowerShell 7.6.0-preview.4 |
| 9.0     | 2024         | Ubuntu 24.04 | Current, includes PowerShell                |
| 8.0     | 2023         | Ubuntu 22.04 | LTS, includes PowerShell 7.4.2              |
| 7.0     | 2022         | Ubuntu 22.04 | Current                                     |
| 6.0     | 2021         | Ubuntu 22.04 | LTS                                         |
| 3.1     | 2019         | Ubuntu 20.04 | LTS (legacy)                                |

---

**Last Updated**: 2024  
**Maintained by**: Darknamer Team  
**Repository**: [Container Repository](https://github.com/darkanmer/container)
