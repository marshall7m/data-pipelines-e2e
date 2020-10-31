#!/usr/bin/env bash

# creates fernet key for secure airflow connection
# : "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
# export AIRFLOW__CORE__FERNET_KEY

if [ -e "requirements.txt" ]; then
  $(command -v pip) install --user -r requirements.txt
fi

# if [ -z "${AIRFLOW__CORE__SQL_ALCHEMY_CONN}" ]; then
#   echo "AIRFLOW__CORE__SQL_ALCHEMY_CONN is not defined. Use: export AIRFLOW__CORE__SQL_ALCHEMY_CONN=" && exit 1
# fi

# use ec2 instance profile credentials for the aws default connection
export AIRFLOW_CONN_AWS_DEFAULT=aws://

case "$1" in
  webserver)
    if [ "$AIRFLOW__CORE__EXECUTOR" = "SequentialExecutor" ]; then
      airflow initdb
    else
      airflow upgradedb
    fi

    if [ "$AIRFLOW__CORE__EXECUTOR" = "SequentialExecutor" ]; then
      airflow scheduler &
    fi
    exec airflow webserver -p 8080
    ;;
  worker|scheduler)
    # Give the webserver time to run initdb.
    sleep 10
    exec airflow "$@"
    ;;
  flower)
    sleep 10
    exec airflow "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac