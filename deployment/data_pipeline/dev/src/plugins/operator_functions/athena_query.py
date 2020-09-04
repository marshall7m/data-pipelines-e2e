from airflow.models import Variable
import boto3
from airflow.contrib.hooks.aws_hook import AwsHook
import time

def athena_query(query, aws_conn_id, region, **kwargs):

    aws = AwsHook(aws_conn_id)
    session = aws.get_session()
    athena = session.client(service_name='athena', region_name=region)

    execution_dict = {
        'year': kwargs['execution_date'].year,
        'month': kwargs['execution_date'].month,
        'day': kwargs['execution_date'].day
    }

    formatted_query = query.format(**execution_dict)
    formatted_output_dir = output_dir.format(**execution_dict)
    
    response = athena.start_query_execution(
        QueryString=formatted_query,
        QueryExecutionContext={
            'Database': database
        },
        ResultConfiguration={
            'OutputLocation': formatted_output_dir
        }
    )

    query_id = response['QueryExecutionId']
    
    state = athena.get_query_execution(QueryExecutionId=query_id)['QueryExecution']['Status']['State']
    while state not in ['SUCCEEDED', 'FAILED', 'CANCELLED']:
        time.sleep(10)
        state = athena.get_query_execution(QueryExecutionId=query_id)['QueryExecution']['Status']['State']
    
    print(f'Query has: {state}')
#['UnprocessedQueryExecutionIds']
    if state == 'FAILED':
        error = athena.batch_get_query_execution(QueryExecutionIds=[query_id])
        print(error)