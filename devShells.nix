{ pkgs, ... }:
let
  shellAliases = import ./utils/shellAliases.nix;
  mariadb = import ./utils/mariadb.nix;
in
{
  # nix develop ".#devShells.node20"
  js = pkgs.mkShell {
    description = "Node.js 20 & Bun";
    buildInputs = with pkgs; [
      nodejs_20
      (nodePackages.yarn.override { nodejs = nodejs_20; })
      bun
      redis
      postgresql
    ];
    shellHook = ''
      ${shellAliases.aliases}
      # init db, create logfile, and start the postgre db
      initdb -D ~/.postgres
      pg_ctl -D ~/.postgres -l logfile start
      pg_ctl -D ~/.postgres status

      # stop database when leaving nix shell
      trap "pg_ctl -D ~/.postgres stop" EXIT
    '';
  };

  # nix develop ".#devShells.php"
  php = pkgs.mkShell {
    description = "PHP 8.3";
    buildInputs = with pkgs; [
      mariadb_110
      redis
      php83
      php83Packages.composer
      (with (php83Extensions); [pdo xml])
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_110}
      ${mariadb.command}
    '';
  };
  # nix develop ".#devShells.php81"
  php81 = pkgs.mkShell {
    description = "PHP 8.1";
    buildInputs = with pkgs; [
      mariadb_110
      php81
      php81Packages.composer
      (with (php83Extensions); [pdo xml])
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_110}
      ${mariadb.command}
    '';
  };

  # nix develop ".#devShells.mariadb"
  mariadb = pkgs.mkShell {
    description = "MariaDB";
    buildInputs = with pkgs; [
      mariadb_110
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_110}
      ${mariadb.command}
    '';
  };

  # nix develop ".#devShells.rust"
  rust = pkgs.mkShell {
    description = "Rust";
    buildInputs = with pkgs; [
      rustc
      cargo
      gcc
      rustfmt
      rustup
    ];
    shellHook = ''
      ${shellAliases.aliases}
    '';
  };

  # wordpress, laravel, and elasticsearch
  # nix develop ".#devshells.wplarasearch"
  wplarasearch = pkgs.mkShell {
    description = "Wordpress, Laravel and ElasticSearch";
    buildInputs = with pkgs; [
      wordpress
      mariadb_110
      php81
      php81Packages.composer
      (with php81Extensions; [ pdo mysqli xml ])
      elasticsearch
      wp-cli
      nginx
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_110}
      ${mariadb.command}

      # Set ES_JAVA_HOME explicitly if needed
      export ES_JAVA_HOME=${pkgs.jdk}
      export ES_HOME=$(dirname $(dirname $(which elasticsearch)))
      export ES_PATH_CONF=$HOME/.config/nix/home-manager/elasticsearch-config

      # Create a log directory with appropriate permissions
      ES_LOG_DIR=$HOME/.config/nix/es-logs
      mkdir -p $ES_LOG_DIR
      chmod 755 $ES_LOG_DIR

      ES_DATA_DIR=$HOME/elasticsearch-data
      mkdir -p $ES_DATA_DIR
      chmod 755 $ES_DATA_DIR

      # Run Elasticsearch with the log directory specified
      elasticsearch -d -Epath.logs=$ES_LOG_DIR -Epath.data=$ES_DATA_DIR
    '';
  };
}
