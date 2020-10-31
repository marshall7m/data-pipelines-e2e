import time
from typing import Dict, List, Optional

from airflow.exceptions import AirflowException
from airflow.hooks import BaseHook

class AwsGlueCrawlerHook(BaseHook):
    def __init__(
        self, 
        crawler_name,
        crawler_poll_interval=10,
        crawler_metrics=True
    ):

        self.crawler_name = crawler_name
        self.crawler_poll_interval = crawler_poll_interval
    
    def list_crawlers(self):
        conn = self.get_conn()
        return conn.list_crawlers()
    
    def trigger_crawler(self):
        glue_client = self.get_conn()

        try:
            crawler_name = self.get_or_create_glue_crawler()
            crawler_run = glue_client.start_crawler(crawler_name)
            return crawler_run
        except Exception as general_error:
            self.log.error("Failed to run aws glue crawler, error: %s", general_error)
            raise
    
    def crawler_completion(self, crawler_name: str) -> Dict[str, str]:
        failed_states = ['FAILED', 'CANCELLED']
        finished_states = ['SUCCEEDED', 'STOPPED']

        while True:
            crawler_run_state = self.get_crawler_state(crawler_name)
            if crawler_run_state in finished_states:
                self.log.info("Exiting Crawler %s Run State: %s", crawler_name, crawler_run_state)
                crawler_state = {'State': crawler_run_state}
                if self.crawler_metrics == True:
                    metrics = self.get_crawler_metrics(crawler_name)
                return crawler_state
            if crawler_run_state in failed_states:
                crawler_error_message = "Exiting Crawler " + crawler_name + " Run State: " + crawler_run_state
                self.log.info(crawler_error_message)
                raise AirflowException(crawler_error_message)
            else:
                self.log.info(
                    "Polling for AWS Glue Crawler %s current run state with status %s", crawler_name, crawler_run_state
                )
                time.sleep(self.crawler_poll_interval)

    def get_crawler_state(self, crawler_name: str):
        glue_client = self.get_conn()
        crawler_run = glue_client.get_crawler(Name=crawler_name)
        crawler_run_state = crawler_run['Crawler']['State']
        return crawler_run_state

    def get_crawler_metrics(self, crawler_name):
        glue_client = self.get_conn()
        crawler = glue_client.get_crawler(Name=crawler_name)

        metrics = crawler['CrawlerMetricsList'][0]
        print('Number of Tables Created: ', metrics['TablesCreated'])
        print('Number of Tables Updated: ', metrics['TablesUpdated'])
        print('Number of Tables Deleted: ', metrics['TablesDeleted'])