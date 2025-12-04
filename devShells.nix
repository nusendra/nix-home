{ pkgs, ... }:
let
  mariadb = import ./utils/mariadb.nix;
  username = builtins.getEnv "USER";

	typesenseServerFixed = pkgs.typesense.overrideAttrs (old: {
    src = pkgs.fetchurl {
      url    = old.src.url;
      sha256 = "yAOR/bGYBQGp8Mllhh0yKyqmItd2+IfLib3W+lIHwr0=";
    };
  });
in
{
	# nix develop ".#devShells.mysql-client"
	mysql-client = pkgs.mkShell {
    description = "Just MySQL Client";
    buildInputs = with pkgs; [
      mariadb_114
    ];

		shellHook = ''
			export PATH="${pkgs.mariadb_114}/bin:$PATH"
			export LDFLAGS="-L${pkgs.mariadb_114}/lib"
			export CPPFLAGS="-I${pkgs.mariadb_114}/include"

			# Start zsh with full configuration
			exec ${pkgs.zsh}/bin/zsh
		'';
	};

  # nix develop ".#devShells.js"
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
      # init db, create logfile, and start the postgre db
      initdb -D ~/.postgres
      pg_ctl -D ~/.postgres -l logfile start
      pg_ctl -D ~/.postgres status

      # stop database when leaving nix shell
      trap "pg_ctl -D ~/.postgres stop" EXIT
      
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
    '';
  };

  # nix develop ".#devShells.onlyjs"
  only-js = pkgs.mkShell {
    description = "Only Node.js";
    buildInputs = with pkgs; [
      nodejs_20
      (nodePackages.yarn.override { nodejs = nodejs_20; })
    ];
    shellHook = ''
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
    '';
  };

  # nix develop ".#devShells.onlyphp"
  only-php = pkgs.mkShell {
    description = "Only PHP 8.1";
    buildInputs = with pkgs; [
      php81
      php81Packages.composer
      (with (php81Extensions); [pdo xml])
    ];
    shellHook = ''
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
    '';
  };

  # nix develop ".#devShells.phpjs"
  php-js = pkgs.mkShell {
    description = "Only PHP 8.3 and JS";
    buildInputs = with pkgs; [
      php83
      php83Packages.composer
			redis
			nodejs_20
			(nodePackages.yarn.override { nodejs = nodejs_20; })
      (with (php83Extensions); [pdo xml redis mongodb])
    ];
    shellHook = ''

      echo "Starting Redis..."
      redis-server --daemonize yes

      echo "PHP configuration:"
      php --ini
      php -m | grep redis
      php -m | grep mongo

			echo "Node.js version:"
			node -v

			echo "Yarn version:"
			yarn -v
			
			# Start zsh with full configuration
			exec ${pkgs.zsh}/bin/zsh
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
      MYSQL_BASEDIR=${pkgs.mariadb_114}
      ${mariadb.command}

      echo "Starting Redis..."
      redis-server --daemonize yes

      echo "extension=/nix/store/jdj6ml38xjsayq5zmgimlxdkbwarsmng-php-mongodb-1.17.3/lib/php/extensions/mongodb.so" > /Users/${username}/.php-extensions/mongodb.ini

      # Set PHP_INI_SCAN_DIR to include the custom directory
      export PHP_INI_SCAN_DIR="/nix/store/yxlsvn4biz4b2r2hajpys297r3yqsj3r-php-with-extensions-8.3.4/lib:/Users/${username}/.php-extensions"

      echo "PHP configuration:"
      php --ini
      php -m | grep redis
      php -m | grep mongo
      
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
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
      MYSQL_BASEDIR=${pkgs.mariadb_114}
      ${mariadb.command}
      
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
    '';
  };

  # nix develop ".#devShells.mariadb"
  mariadb = pkgs.mkShell {
    description = "MariaDB";
    buildInputs = with pkgs; [
      mariadb_114
    ];
    shellHook = ''
      MYSQL_BASEDIR=${pkgs.mariadb_114}
      ${mariadb.command}
      
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
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
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
    '';
  };

  # nix develop ".#devShells.js-rust"
  js-rust = pkgs.mkShell {
    description = "JavaScript (Node.js) and Rust";
    buildInputs = with pkgs; [
      nodejs_20
      (nodePackages.yarn.override { nodejs = nodejs_20; })
      rustc
      cargo
      gcc
      rustfmt
      rustup
      pkg-config
    ];
    shellHook = ''
      echo "🚀 JavaScript & Rust Development Environment"
      echo "Node.js version: $(node --version)"
      echo "Yarn version: $(yarn --version)"
      echo "Rust version: $(rustc --version)"
      echo "Cargo version: $(cargo --version)"
      
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
    '';
  };

  # nix develop ".#devShells.typesense"
  typesense = pkgs.mkShell {
    description = "Typesense";
    buildInputs = with pkgs; [
			typesenseServerFixed
			curl
			jq
    ];
    shellHook = ''

			# ensure data dir exists
			export typesenseDataDir="$HOME/.typesense-data"
			mkdir -p "$typesenseDataDir"

			# Start Typesense on port 8108 with an example API key
			if ! pgrep -f "typesense-server"; then
				echo "🚀 Launching Typesense server…"
				typesense-server \
					--data-dir="$typesenseDataDir" \
					--api-key="xyz123" \
					--listen-port=8108 \
					--enable-cors="*" \
					--log-level=debug \
					&> typesense.log &
				echo "   → PID $!"
				echo "   → Logs → typesense.log"
			else
				echo "✅ Typesense already running (pid $(pgrep -f typesense-server))"
			fi

			echo ""
			echo "To test: curl -H \"X-TYPESENSE-API-KEY: xyz123\" http://localhost:8108/health"
			
			# Start zsh with full configuration
			exec ${pkgs.zsh}/bin/zsh
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
      
      # Start zsh with full configuration
      exec ${pkgs.zsh}/bin/zsh
    '';
  };
}
