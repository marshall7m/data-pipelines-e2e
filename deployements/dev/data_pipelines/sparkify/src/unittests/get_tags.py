import boto3
import os
from collections import Counter
import yaml
from collections import defaultdict
# from airflow.models.dagbag import DagBag


def create_dag_config(tag_filter_dict, dag_id, output_config_path):
    client = boto3.client('resourcegroupstaggingapi')
    tag_filters = [{'Key': key, 'Values': [value]} if value != None else {'Key': key} for key,value in tag_filter_dict.items()]
    response = client.get_resources(
        TagFilters=tag_filters,
        ResourcesPerPage=20
    )
    task_resource_count_dict = defaultdict(int)
    task_resource_dict = defaultdict(list)
    for resource in response['ResourceTagMappingList']:
        resource_name = resource['ResourceARN'].split('/')[-1]

        for tag_dict in resource['Tags']:
            if 'task_id' in list(tag_dict.values()):
                task = list(tag_dict.values())[-1]
                task_resource_count_dict[task] += 1
                task_resource_dict[task].append(resource_name)
                break
    
    dag_dict = defaultdict(dict)
    dag_dict[dag_id]['task_resource_count'] = dict(task_resource_count_dict)
    dag_dict[dag_id]['task_resources'] = dict(task_resource_dict)
    dag_dict = dict(dag_dict)
    
    class CustomDumper(yaml.Dumper):
        def increase_indent(self, flow=False, indentless=False):
            return super(CustomDumper, self).increase_indent(flow, False)
    
    try:
        with open(output_config_path, 'r') as f:
            current_dag_config = yaml.safe_load(f)
            updated_config = dag_dict.update(current_dag_config)
    except Exception:
        print(f"Creating new task count file as: {output_config_path}")

    with open(output_config_path, 'w') as f:
        updated_config = yaml.dump(dag_dict, f, Dumper=CustomDumper, default_flow_style=False)


# dag_list = DagBag(dag_folder='../dags/')
dag_list = ['sparkify_etl', 'sparkify_analytics']
for dag in dag_list:

    tag_filter_dict = {
        'client': 'sparkify',
        'dag_id': dag,
        'task_id': None
    }

    create_dag_config(tag_filter_dict, dag, 'cfg/dags_aws_resources.yaml')





