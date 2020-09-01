docker build . \
    --tag $IMAGE_REPO_NAME:$IMAGE_TAG
    --build-arg DAGS_FOLDER="dags/"
    --build-arg PLUGINS_FOLDER="plugins/"
    --build-arg AIRFLOW_CONFIG="airflow.cfg"

docker push $IMAGE_REPO_NAME:$IMAGE_TAG