AIRFLOW__CORE__SQL_ALCHEMY_CONN=$(aws ssm get-parameters --region us-east-1 --names AIRFLOW__CORE__SQL_ALCHEMY_CONN --with-decryption --query Parameters[0].Value)
export AIRFLOW__CORE__SQL_ALCHEMY_CONN

docker run  upgrade db
