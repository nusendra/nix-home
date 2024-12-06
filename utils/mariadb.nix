{
  command=''
      MYSQL_HOME=$PWD/mysql
      MYSQL_DATADIR=$MYSQL_HOME/data
      export MYSQL_UNIX_PORT=$MYSQL_HOME/mysql.sock
      MYSQL_PID_FILE=$MYSQL_HOME/mysql.pid
      MYSQL_PASSWORD="password"
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

      # Set root password if not already set
      if ! mysql --socket=$MYSQL_UNIX_PORT -e "SELECT 1;" &>/dev/null; then
        mysql --socket=$MYSQL_UNIX_PORT -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;"
        echo "Root password set to '$MYSQL_PASSWORD'."
      else
        echo "Root password already set."
      fi

      finish() {
        mysqladmin -u root --socket=$MYSQL_UNIX_PORT shutdown
        kill $(cat $MYSQL_PID_FILE)
        wait $(cat $MYSQL_PID_FILE)
      }
      trap finish EXIT
  '';
}
