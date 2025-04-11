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
      mariadb_114
      redis
      php83
      php83Packages.composer
      (with (php83Extensions); [pdo xml redis mongodb])
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_114}
      ${mariadb.command}

      echo "Starting Redis..."
      redis-server --daemonize yes

      echo "extension=/nix/store/jdj6ml38xjsayq5zmgimlxdkbwarsmng-php-mongodb-1.17.3/lib/php/extensions/mongodb.so" > /Users/nusendra/.php-extensions/mongodb.ini

      # Set PHP_INI_SCAN_DIR to include the custom directory
      export PHP_INI_SCAN_DIR="/nix/store/yxlsvn4biz4b2r2hajpys297r3yqsj3r-php-with-extensions-8.3.4/lib:/Users/nusendra/.php-extensions"

      echo "PHP configuration:"
      php --ini
      php -m | grep redis
      php -m | grep mongo
    '';
  };
  # nix develop ".#devShells.php81"
  php81 = pkgs.mkShell {
    description = "PHP 8.1";
    buildInputs = with pkgs; [
      mariadb_114
      php81
      php81Packages.composer
      (with (php83Extensions); [pdo xml])
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_114}
      ${mariadb.command}
    '';
  };

  # nix develop ".#devShells.mariadb"
  mariadb = pkgs.mkShell {
    description = "MariaDB";
    buildInputs = with pkgs; [
      mariadb_114
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_114}
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

  # elasticsearch
  # nix develop ".#devshells.elasticsearch"
  elasticsearch = pkgs.mkShell {
    description = "ElasticSearch";
    buildInputs = with pkgs; [
      elasticsearch
    ];
    shellHook = ''
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
      elasticsearch -d
    '';
  };
}
