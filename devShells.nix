{ pkgs, ... }:
let
  shellAliases = import ./utils/shellAliases.nix;
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
    ];
    shellHook = ''
      ${shellAliases.aliases}
    '';
  };

  # nix develop ".#devShells.node18"
  php = pkgs.mkShell {
    description = "PHP 8.3";
    buildInputs = with pkgs; [
      mariadb_110
      php83
      php83Packages.composer
      (with (php83Extensions); [pdo xml])
    ];
    shellHook = ''
      ${shellAliases.aliases}
      MYSQL_BASEDIR=${pkgs.mariadb_110}
      MYSQL_HOME=$PWD/mysql
      MYSQL_DATADIR=$MYSQL_HOME/data
      export MYSQL_UNIX_PORT=$MYSQL_HOME/mysql.sock
      MYSQL_PID_FILE=$MYSQL_HOME/mysql.pid
      alias mysql='mysql -u root'

      if [ ! -d "$MYSQL_HOME" ]; then
        mkdir -p $MYSQL_HOME
        mysql_install_db --auth-root-authentication-method=normal \
          --datadir=$MYSQL_DATADIR --basedir=$MYSQL_BASEDIR \
          --pid-file=$MYSQL_PID_FILE
      fi

      # Start MySQL if not already running
      if ! ps -p $(cat $MYSQL_PID_FILE) > /dev/null; then
        mysqld --datadir=$MYSQL_DATADIR --pid-file=$MYSQL_PID_FILE \
          --socket=$MYSQL_UNIX_PORT > $MYSQL_HOME/mysql.log 2>&1 &
      fi

      # Check if MySQL started successfully
      sleep 5
      if ! ps -p $(cat $MYSQL_PID_FILE) > /dev/null; then
        echo "Failed to start MySQL. Check $MYSQL_HOME/mysql.log for details."
        exit 1
      fi

      finish() {
        mysqladmin -u root --socket=$MYSQL_UNIX_PORT shutdown
        kill $(cat $MYSQL_PID_FILE)
        wait $(cat $MYSQL_PID_FILE)
      }
      trap finish EXIT
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
}
