docker build . \
    --tag $ECR_REPO_URL:$IMAGE_TAG \
    --build-arg AIRFLOW_IMG_TAG="1.10.11" \
    --build-arg DAGS_FOLDER="dags/" \
    --build-arg PLUGINS_FOLDER="plugins/" \
    --build-arg CONFIG_FOLDER="cfg/" \
    --build-arg REQUIREMENTS_TXT="requirements.txt" \
    --build-arg AIRFLOW_CONSTRAINTS_URL="https://raw.githubusercontent.com/apache/airflow/constraints-1.10.11/constraints-3.6.txt"

