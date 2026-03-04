# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Environment Setup

This is a Nix configuration repository for a macOS development environment (aarch64-darwin). The setup uses Nix flakes and home-manager for reproducible development shells.

### Home Manager Configuration

Apply home-manager configuration:
```bash
home-manager switch --flake .#nusendra
```

### Development Shells

The repository provides multiple development environments via `nix develop`. Each shell is defined in `devShells.nix`:

**Available Development Shells:**
- `nix develop ".#devShells.php"` - PHP 8.3 with MariaDB 11.4 and Redis
- `nix develop ".#devShells.php81"` - PHP 8.1 with MariaDB 11.4
- `nix develop ".#devShells.js"` - Node.js 20, Yarn, Bun, Redis, PostgreSQL
- `nix develop ".#devShells.php-js"` - PHP 8.3 and Node.js 20 combined
- `nix develop ".#devShells.only-php"` - Only PHP 8.1 without databases
- `nix develop ".#devShells.only-js"` - Only Node.js 20 without databases
- `nix develop ".#devShells.rust"` - Rust development environment
- `nix develop ".#devShells.mariadb"` - MariaDB 11.4 only
- `nix develop ".#devShells.mysql-client"` - MySQL client only
- `nix develop ".#devShells.typesense"` - Typesense search server
- `nix develop ".#devShells.elasticsearch"` - ElasticSearch server
- `nix develop ".#devShells.ployer"` - Ployer PaaS (Rust, Node.js 24, Caddy, SQLite, Docker)

**Shell Aliases for Development Environments:**
The home-manager configuration provides convenient aliases:
- `devphp` - Enter PHP 8.3 shell
- `devphp81` - Enter PHP 8.1 shell
- `devjs` - Enter Node.js shell
- `devphpjs` - Enter combined PHP/JS shell
- `devonlyphp` - Enter PHP-only shell
- `devonlyjs` - Enter JS-only shell
- `devrust` - Enter Rust shell
- `devmariadb` - Enter MariaDB shell
- `devmysqlclient` - Enter MySQL client shell
- `devtypesense` - Enter Typesense shell
- `develasticsearch` - Enter ElasticSearch shell (requires `NIXPKGS_ALLOW_UNFREE=1`)
- `devployer` - Enter Ployer PaaS development shell (Rust + Node.js 24 + Caddy + Docker)

## Database Configuration

### MariaDB Setup
- MariaDB runs locally in `$PWD/mysql/` directory
- Data directory: `$PWD/mysql/data/`
- Socket: `$PWD/mysql/mysql.sock`  
- Default root password: "password"
- Auto-starts when entering PHP shells
- Auto-stops when exiting shell

### PostgreSQL Setup (JS shell)
- Initializes database in `~/.postgres`
- Auto-starts when entering JS shell
- Auto-stops when exiting shell

### Redis Setup
- Runs as daemon when entering PHP or JS shells
- Uses default Redis configuration

## Architecture & Structure

### Core Files
- `flake.nix` - Main Nix flake configuration defining inputs and outputs
- `devShells.nix` - Development shell definitions and configurations
- `home-manager/home.nix` - Home-manager configuration for user environment
- `utils/shellAliases.nix` - Common shell aliases shared across environments
- `utils/mariadb.nix` - MariaDB initialization and management scripts

### Home Manager Structure
- `home-manager/nvim/` - Neovim configuration
- `home-manager/elasticsearch-config/` - ElasticSearch configuration files

### Data Directories
- `mysql/` - MariaDB data and configuration (auto-created)
- `es-logs/` - ElasticSearch logs directory
- Various database directories are created automatically in user home

## Common Git Aliases

The configuration includes extensive Git aliases available in all shells:
- `gs` - git status
- `gd` - git diff  
- `ga` - git add .
- `gcom` - git commit -m
- `glo` - git log --oneline
- `gcb` - git checkout -b
- `gplom/gploma/gplod` - pull from origin master/main/dev
- `gpsom/gpsoma/gpsod` - push to origin master/main/dev

## Docker Aliases

Docker Compose shortcuts for different environments:
- `dcb/dcu/dcud/dcd` - build/up/up-daemon/down for default compose
- `dcbdev/dcudev/dcuddev/dcddev` - same for docker-compose.dev.yml
- `dcbprod/dcuprod/dcudprod/dcdprod` - same for docker-compose.prod.yml

## Key Features

- **Multi-language support**: PHP, JavaScript/Node.js, Rust
- **Database integration**: MariaDB, PostgreSQL, Redis automatically managed
- **Search engines**: Typesense and ElasticSearch support
- **Reproducible environments**: Each shell provides isolated, consistent tooling
- **Auto-cleanup**: Databases and services stop automatically when exiting shells
- **Cross-platform**: Designed for macOS (aarch64-darwin) but adaptable