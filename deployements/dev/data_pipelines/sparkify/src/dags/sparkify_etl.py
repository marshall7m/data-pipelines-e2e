from datetime import datetime, timedelta, timezone
import os
from configparser import ConfigParser

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.subdag_operator import SubDagOperator
from operator_functions.glue_crawler import run_glue_crawler
from operator_functions.glue_job import run_glue_job

import yaml
from pathlib import Path

with open('cfg/dags_config.yaml') as f:
    config = yaml.safe_load(f)

    # default_config = json.loads(json.dumps(default_config, default=str))  # Serialize datetimes to strings

with DAG(**config['dags']['sparkify_etl']) as dag:

    start_operator = DummyOperator(task_id='Begin_execution')

    crawl_source_s3 = PythonOperator(
        task_id='crawl_source_s3', 
        python_callable=run_glue_crawler,
        op_kwargs = {'crawler_name': 'sparkify-usr-olap-dev-glue-crawler-raw'},
        provide_context=True
    )
    
    glue_jobs = PythonOperator(
        task_id='process_sparkify',
        python_callable=run_glue_job,
        op_kwargs = {'job_name': 'sparkify-usr-olap-dev-glue-job-process-raw'},
        provide_context=True
    )

    crawl_parquet_s3 = PythonOperator(
        task_id='crawl_parquet_s3',
        python_callable=run_glue_crawler,
        templates_dict=config['default_args'],
        op_kwargs = {'crawler_name': 'sparkify-usr-olap-dev-glue-crawler-parquet'},
        provide_context=True
    )

    start_operator >> crawl_source_s3 >> glue_jobs >> crawl_parquet_s3


