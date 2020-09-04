git clone https://github.com/apache/airflow.git

cd airflow

git checkout v1-10-stable

docker build . \
    --tag $IMAGE_REPO_NAME:$IMAGE_TAG
    --build-arg AIRFLOW_INSTALL_VERSION="1.10.13"
    --build-arg AIRFLOW_EXTRAS="aws,postgres"
    --build-arg ADDITIONAL_PYTHON_DEPS="cryptography==2.9.2"
    --build-arg AIRFLOW_HOME="usr/local/airflow"
    --build-arg PYTHON_BASE_IMAGE="python:3.6-slim-buster"
    --build-arg PYTHON_MAJOR_MINOR_VERSION="3.6"
