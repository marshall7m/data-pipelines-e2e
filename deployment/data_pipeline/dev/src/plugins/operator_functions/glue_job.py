import boto3
import time
from airflow.contrib.hooks.aws_hook import AwsHook
from airflow import AirflowException

def run_glue_job(job_name, catalog_database, output_dir, aws_conn_id, region, reset_bookmark, **kwargs):
    """
    job_name -- AWS Glue job name
    """
    aws = AwsHook(aws_conn_id)
    session = aws.get_session()
    glue = session.client('glue', region_name=region)
    s3 = session.resource('s3')
    
    year = kwargs['execution_date'].year
    month = kwargs['execution_date'].month
    day = kwargs['execution_date'].day

    if reset_bookmark == True:
        print(f'Resetting {job_name} bookmark')
        glue.reset_job_bookmark(JobName=job_name)
 
    job_run = glue.start_job_run(
               JobName=job_name,
               Arguments = {
                # '--output_dir': output_dir,
                # '--catalog_database': catalog_database,
                # '--job-bookmark-option': 'job-bookmark-enable',
                '--year': str(year),
                '--month': str(month),
                '--day': str(day)})
    job_id = job_run['JobRunId']
    status = glue.get_job_run(JobName=job_name, RunId=job_run['JobRunId'])['JobRun']['JobRunState']

    while status not in ['SUCCEEDED', 'FAILED', 'STOPPED']:
        time.sleep(20)
        status = glue.get_job_run(JobName=job_name, RunId=job_id)['JobRun']['JobRunState']
        
    print(f'Job ID: {job_id}')
    print(f'Status: {status}')

    if status == 'FAILED':
        error = glue.get_job_run(JobName=job_name, RunId=job_run['JobRunId'])['JobRun']['ErrorMessage']
        print('ERROR OUTPUT: ')
        print(error)
        if error == "AnalysisException: u'Partition column year not found in schema StructType();'":
            print(f'No new data from source S3 resulted in no new data added to {output_dir}')
        else:
            raise AirflowException
    
