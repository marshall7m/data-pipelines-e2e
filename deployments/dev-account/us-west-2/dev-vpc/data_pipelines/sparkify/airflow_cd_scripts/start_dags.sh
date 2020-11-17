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

