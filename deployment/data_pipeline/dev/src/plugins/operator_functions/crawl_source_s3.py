import boto3
from airflow.contrib.hooks.aws_hook import AwsHook
import time
from airflow import AirflowException

def crawl_s3(crawler_tags=None, check_interval=50, **kwargs):

    aws = AwsHook(kwargs['aws_conn_id'])
    session = aws.get_session()

    glue = session.client(service_name='glue', region_name=kwargs['region'])

    if crawler_tags:
        crawler_list = glue.list_crawlers(Tags=crawler_tags)
    else:
        crawler_list = glue.list_crawlers(Tags={
            kwargs['dag_id'],
            kwargs['task_id'],
            kwargs['environment']
            }
        )
    for crawler in crawler_list['CrawlerNames']:
        print(f'Starting Crawler: {crawler}')
        response = glue.start_crawler(Name=crawler)
    
    crawlers_running = crawler_list
    while crawlers_running:
        time.sleep(check_interval)
        for crawler_name in crawler_list:
            print(f'Crawler: {crawler_name}')
            crawler = glue.get_crawler(Name=crawler_name)
            crawler_state = crawler['Crawler']['State']     
            if crawler_state == 'RUNNING':
                print('Crawler State: ', crawler_state)
                metrics = crawler['CrawlerMetricsList'][0]
                if metrics['StillEstimating'] == True:
                    print('Estimated Time Left: Still Estimating')
                else:
                    time_left = int(metrics['TimeLeftSeconds'])
                    if time_left > 0:
                        print('Estimated Time Left: ', time_left)
                        sleep_secs = time_left
                    else:
                        print('Crawler should finish soon')
            elif crawler_state in ['CANCELLED','FAILED']:
                print('Crawler State: ', crawler_state)
                raise AirflowException
            else:
                metrics = crawler_dict['CrawlerMetricsList'][0]
                crawler_status = crawler_dict['Crawler']['LastCrawl']['Status']

                print('Crawler Status: ', crawler_status)
                print('Table Metrics:')
                print('Number of Tables Created: ', metrics['TablesCreated'])
                print('Number of Tables Updated: ', metrics['TablesUpdated'])
                print('Number of Tables Deleted: ', metrics['TablesDeleted'])
                
                crawlers_running.remove(crawler_name)

        