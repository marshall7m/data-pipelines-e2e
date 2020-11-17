AIRFLOW__CORE__SQL_ALCHEMY_CONN=$(aws ssm get-parameters --names sparkify-usr-olap-dev-airflow-db-postgres-conn --with-decryption)
AIRFLOW__CORE__FERNET_KEY=$(aws ssm get-parameters --names sparkify-usr-olap-dev-airflow-fernet-key --with-decryption)

export AIRFLOW__CORE__SQL_ALCHEMY_CONN
export AIRFLOW__CORE__FERNET_KEY

docker compose up
