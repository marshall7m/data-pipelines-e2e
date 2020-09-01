docker build . \
    --tag $IMAGE_REPO_NAME:$IMAGE_TAG
    --build-arg REQUIREMENTS_TXT="/requirements.txt"
    --build-arg AIRFLOW_CONSTRAINTS_URL="https://raw.githubusercontent.com/apache/airflow/constraints-1.10.12/constraints-3.7.txt"
