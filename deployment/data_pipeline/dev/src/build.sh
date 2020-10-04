docker build . \
    --tag $ECR_REPO_URL:$IMAGE_TAG \
    --build-arg AIRFLOW_IMG_TAG="1.10.11" 
