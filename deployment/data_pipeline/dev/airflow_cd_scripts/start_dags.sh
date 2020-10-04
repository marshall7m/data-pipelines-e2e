# docker run  -v $(pwd)/dags:/opt/airflow/dags \
# -v $(pwd)/plugins:/opt/airflow/plugins \
# -v $(pwd)/cfg:/opt/airflow/cfg \
# $ECR_REPO_URL:$IMAGE_TAG dag_state sparkify_analytics

target_instances_ids=$(aws deploy list-deployment-targets \
    --deployment-id $DEPLOYMENT_ID)["targetIds"]

for id in $target_instances_ids; do
    start_all_dags = $(aws rds-data execute-statement \
    --database  "prod_db" \
    --schema  $id \
    --sql """
        UPDATE dag
        SET is_paused = FALSE
        WHERE is_paused is TRUE;
    """)

