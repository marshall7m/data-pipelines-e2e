from datetime import datetime, timedelta, timezone
import os
from configparser import ConfigParser

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.subdag_operator import SubDagOperator
from operator_functions.crawl_source_s3 import crawl_s3
from operator_functions.glue_job import run_glue_job
from operator_functions.athena_query import athena_query
from operator_queries.sql_queries import SqlQueries

import yaml
from pathlib import Path

with open('cfg/sparkify_analytics_config.yml') as f:
    config = yaml.safe_load(f)

with DAG(
    default_args=config['default_args'], 
    user_defined_macros=config['default_args'],
    start_date=datetime(year=2018, month=11, day=11, tzinfo=timezone.utc),
    end_date=datetime(year=2018, month=11, day=11, tzinfo=timezone.utc),
    **config['dags']['sparkify_analytics']
    ) as dag:

    start_operator = DummyOperator(task_id='Begin_execution')

    crawl_source_s3 = PythonOperator(
        task_id='crawl_source_s3', 
        python_callable=crawl_s3,
        templates_dict=config['default_args'],
        provide_context=True
    )

    glue_jobs = PythonOperator(
        task_id='process_sparkify',
        python_callable=run_glue_job,
        templates_dict=config['default_args'],
        provide_context=True
    )

    crawl_parquet_s3 = PythonOperator(
        task_id='crawl_parquet_s3',
        python_callable=crawl_s3,
        templates_dict=config['default_args'],
        provide_context=True
    )

    query_db = PythonOperator(
        task_id='athena_queries',
        python_callable=athena_query,
        templates_dict=config['default_args'],
        provide_context=True
    )

    start_operator >> crawl_source_s3 >> glue_jobs >> crawl_parquet_s3 >> query_db


