# Container Repository

A comprehensive Docker container repository providing pre-built, optimized images for .NET, Laravel (PHP), and Ubuntu-based development environments.

## 📋 Table of Contents

- [Overview](#overview)
- [Available Containers](#available-containers)
- [Quick Start](#quick-start)
- [Container Details](#container-details)
- [CI/CD Pipeline](#cicd-pipeline)
- [Usage Examples](#usage-examples)
- [Contributing](#contributing)
- [Maintenance](#maintenance)

## 🎯 Overview

This repository maintains a collection of production-ready Docker containers designed for modern development workflows. All containers are automatically built and published via GitHub Actions to DockerHub and GitHub Container Registry.

### Key Features

- **Multi-version support**: Multiple versions of .NET (3.1 through 10.0) and PHP (7.0, 7.4, 8.0)
- **Optimized builds**: Containers are optimized for size and performance
- **Automated CI/CD**: Automatic builds and publishing on push to master/main branches
- **Multi-registry publishing**: Images published to both DockerHub and GitHub Container Registry
- **Production-ready**: Includes necessary tools, extensions, and configurations

## 📦 Available Containers

### .NET Containers

Available on DockerHub as `unnamed22090/dotnet`:

| Version | Variants                           | Tags                                                           |
| ------- | ---------------------------------- | -------------------------------------------------------------- |
| 3.1     | runtime-deps, runtime, aspnet, sdk | `runtime-deps-3.1`, `runtime-3.1`, `aspnet-3.1`, `sdk-3.1`     |
| 6.0     | runtime-deps, runtime, aspnet, sdk | `runtime-deps-6.0`, `runtime-6.0`, `aspnet-6.0`, `sdk-6.0`     |
| 7.0     | runtime-deps, runtime, aspnet, sdk | `runtime-deps-7.0`, `runtime-7.0`, `aspnet-7.0`, `sdk-7.0`     |
| 8.0     | runtime-deps, runtime, aspnet, sdk | `runtime-deps-8.0`, `runtime-8.0`, `aspnet-8.0`, `sdk-8.0`     |
| 9.0     | runtime-deps, runtime, aspnet, sdk | `runtime-deps-9.0`, `runtime-9.0`, `aspnet-9.0`, `sdk-9.0`     |
| 10.0    | runtime-deps, runtime, aspnet, sdk | `runtime-deps-10.0`, `runtime-10.0`, `aspnet-10.0`, `sdk-10.0` |

**Container Variants Explained:**

- **runtime-deps**: Minimal runtime dependencies only
- **runtime**: Full .NET runtime
- **aspnet**: ASP.NET Core runtime
- **sdk**: Full .NET SDK with development tools (includes PowerShell)

### Laravel Containers

Available on DockerHub as `unnamed22090/laravel`:

| PHP Version | Tags                            | Features                                            |
| ----------- | ------------------------------- | --------------------------------------------------- |
| 7.0         | `laravel:7.0`                   | Nginx, PHP-FPM, Supervisor, Laravel Horizon support |
| 7.4         | `laravel:7.4`                   | Nginx, PHP-FPM, Supervisor, Laravel Horizon support |
| 8.0         | `laravel:8.0`, `laravel:latest` | Nginx, PHP-FPM, Supervisor, Laravel Horizon support |

**Included Components:**

- Nginx web server (1.20.2)
- PHP-FPM with Alpine Linux base
- Supervisor for process management
- Pre-configured PHP extensions: bcmath, gd, gettext, intl, opcache, pcntl, soap, zip, mysqli, pdo_mysql, pgsql, pdo_pgsql, xsl, imap
- PECL extensions: apcu, imagick, redis
- Optimized PHP settings (1GB upload limits, opcache enabled)

### Ubuntu Base Containers

Available on DockerHub as `unnamed22090/ubuntu`:

| Version      | Tags                           | Description                        |
| ------------ | ------------------------------ | ---------------------------------- |
| Ubuntu 20.04 | `ubuntu:focal`, `ubuntu:20.04` | Base Ubuntu with development tools |
| Ubuntu 22.04 | `ubuntu:jammy`, `ubuntu:22.04` | Base Ubuntu with development tools |

**Included Tools:**

- Git, Mercurial, Subversion, Bazaar
- SSH client
- System.Drawing dependencies (libgdiplus)
- Timezone configured to Asia/Bangkok
- Additional tools available via scripts (MariaDB, MongoDB, Python)

## 🚀 Quick Start

### Pull and Run .NET Container

```bash
# Pull .NET SDK 10.0
docker pull unnamed22090/dotnet:sdk-10.0

# Run a .NET application
docker run -it --rm unnamed22090/dotnet:sdk-10.0 dotnet --version
```

### Pull and Run Laravel Container

```bash
# Pull Laravel container
docker pull unnamed22090/laravel:8.0

# Run Laravel application
docker run -d -p 80:80 \
  -v $(pwd):/var/www/html \
  unnamed22090/laravel:8.0
```

### Pull and Run Ubuntu Container

```bash
# Pull Ubuntu base container
docker pull unnamed22090/ubuntu:22.04

# Run Ubuntu container
docker run -it --rm unnamed22090/ubuntu:22.04 bash
```

## 📚 Container Details

### Directory Structure

```
container/
├── containers/
│   ├── dotnet/              # .NET containers
│   │   ├── 3.1/            # .NET 3.1 variants
│   │   ├── 6.0/            # .NET 6.0 variants
│   │   ├── 7.0/            # .NET 7.0 variants
│   │   ├── 8.0/            # .NET 8.0 variants
│   │   ├── 9.0/            # .NET 9.0 variants
│   │   └── 10.0/           # .NET 10.0 variants
│   ├── laravel/            # Laravel/PHP containers
│   │   └── mains/
│   │       ├── 7.0/        # PHP 7.0 Laravel container
│   │       ├── 7.4/        # PHP 7.4 Laravel container
│   │       └── 8.0/        # PHP 8.0 Laravel container
│   └── ubuntu/             # Ubuntu base containers
│       ├── focal/          # Ubuntu 20.04
│       ├── jammy/          # Ubuntu 22.04
│       └── cmd/            # Additional tool scripts
├── .github/
│   ├── workflows/          # GitHub Actions workflows
│   └── archives/           # Archived workflow configurations
└── env/                    # Environment configuration files
```

### .NET Container Architecture

.NET containers follow a layered architecture:

1. **runtime-deps**: Base layer with minimal dependencies
2. **runtime**: Built on runtime-deps, includes full .NET runtime
3. **aspnet**: Built on runtime, includes ASP.NET Core
4. **sdk**: Built on aspnet, includes development tools and PowerShell

### Laravel Container Architecture

Laravel containers are based on `php:8.0-fpm-alpine3.15` and include:

- Multi-stage build for optimization
- Supervisor manages both Nginx and PHP-FPM processes
- Custom entrypoint script for initialization
- Pre-configured Nginx with Laravel-friendly settings
- PHP extensions compiled and optimized for production

## 🔄 CI/CD Pipeline

### Automated Builds

Containers are automatically built and published when changes are pushed to:

- `master` branch (all containers)
- `main` branch (Laravel containers)
- `develop` branch (Laravel containers)

### Workflow Files

- **`.github/workflows/dotnet.yaml`**: Builds and publishes .NET containers (currently configured for 10.0)
- **`.github/archives/ubuntu.yaml`**: Builds and publishes Ubuntu base containers
- **`.github/archives/laravel-php80.yaml`**: Builds and publishes Laravel PHP 8.0 containers
- **`.github/archives/laravel-php74.yaml`**: Builds and publishes Laravel PHP 7.4 containers
- **`.github/archives/laravel-php70.yaml`**: Builds and publishes Laravel PHP 7.0 containers

### Publishing Targets

Images are published to:

1. **DockerHub**: `unnamed22090/*`
2. **GitHub Container Registry**: `ghcr.io/*`

### Required Secrets

The following secrets must be configured in GitHub:

- `DOCKERHUB_USERNAME`: DockerHub username
- `DOCKERHUB_TOKEN`: DockerHub access token
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions

## 💡 Usage Examples

### Example 1: .NET Web API Development

```dockerfile
FROM unnamed22090/dotnet:sdk-10.0 AS build
WORKDIR /app
COPY . .
RUN dotnet publish -c Release -o /out

FROM unnamed22090/dotnet:aspnet-10.0
WORKDIR /app
COPY --from=build /out .
EXPOSE 80
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### Example 2: Laravel Application

```dockerfile
FROM unnamed22090/laravel:8.0
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader
EXPOSE 80
```

### Example 3: Custom Ubuntu Build

```dockerfile
FROM unnamed22090/ubuntu:22.04
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip
# Your custom setup here
```

### Example 4: Docker Compose for Laravel

```yaml
version: "3.8"
services:
  app:
    image: unnamed22090/laravel:8.0
    ports:
      - "8080:80"
    volumes:
      - ./:/var/www/html
    environment:
      - APP_ENV=local
```

## 🤝 Contributing

### Adding a New Container Version

1. Create the appropriate directory structure under `containers/`
2. Add Dockerfile with proper configuration
3. Update or create GitHub Actions workflow
4. Test the build locally before pushing
5. Update this README with new container information

### Local Testing

```bash
# Build a container locally
docker build -t test-container -f containers/dotnet/10.0/sdk/Dockerfile .

# Test the container
docker run -it --rm test-container dotnet --version
```

### Best Practices

- Keep Dockerfiles minimal and focused
- Use multi-stage builds when possible
- Remove unnecessary packages to reduce image size
- Document any special configurations
- Test containers before pushing to master

## 🔧 Maintenance

### Updating Container Versions

1. Update the version in the Dockerfile
2. Update the tag in the GitHub Actions workflow
3. Test the build
4. Push to master to trigger automated build

### Monitoring

- Check GitHub Actions for build status
- Monitor DockerHub for published images
- Review container sizes and optimize if needed

### Deprecation Policy

- Old versions are maintained for compatibility
- Deprecated versions will be marked in this README
- Users should migrate to supported versions

## 📝 Notes

- All containers are built for `linux/amd64` platform
- Laravel containers use Alpine Linux for smaller image size
- .NET containers include PowerShell in SDK variants
- Timezone is set to Asia/Bangkok in Ubuntu containers
- PHP upload limits are set to 1GB in Laravel containers

## 🔗 References

- [.NET Docker Repository](https://github.com/dotnet/dotnet-docker)
- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)

## 📧 Contact

For issues, questions, or contributions, please open an issue in this repository.

---

**Last Updated**: 2024
**Maintained by**: Darknamer Team
