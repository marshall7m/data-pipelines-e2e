ARG AIRFLOW_IMG_TAG
FROM apache/airflow:$AIRFLOW_IMG_TAG

USER airflow

ARG REQUIREMENTS_TXT=""
COPY --chown=airflow:root $REQUIREMENTS_TXT ${AIRFLOW_HOME}

RUN pip install --user -r "requirements.txt"

ARG CONFIG_FOLDER=""
COPY --chown=airflow:root $CONFIG_FOLDER ${AIRFLOW_HOME}/cfg/

ARG DAGS_FOLDER=""
COPY --chown=airflow:root $DAGS_FOLDER ${AIRFLOW_HOME}/dags/

ARG PLUGINS_FOLDER=""
COPY --chown=airflow:root $PLUGINS_FOLDER ${AIRFLOW_HOME}/plugins/

