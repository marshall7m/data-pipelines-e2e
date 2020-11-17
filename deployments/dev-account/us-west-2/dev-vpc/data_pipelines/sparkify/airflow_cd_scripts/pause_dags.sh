target_instances_ids=$(aws deploy list-deployment-targets \
    --deployment-id $DEPLOYMENT_ID)["targetIds"]

for id in $target_instances_ids; do
    running_dags_list = $(aws rds-data execute-statement \
        --database  "prod_db" \
        --schema  $id \
        --sql """
            SELECT 
                dag_id
            FROM dag
            WHERE is_paused IS FALSE;
        """)
    
    pause_all_dags = $(aws rds-data execute-statement \
        --database  "prod_db" \
        --schema  $id \
        --sql """
            UPDATE dag
            SET is_paused = TRUE
            WHERE is_paused is FALSE;
        """)