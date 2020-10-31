docker build . \
    --tag airflow_test:latest \
    --build-arg AIRFLOW_IMG_TAG="1.10.11"  \
    --build-arg REQUIREMENTS_TXT="./requirements.txt" \
    --build-arg ENTRYPOINT_SH="./scripts/entrypoint.sh"