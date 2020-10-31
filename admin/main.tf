/* 
Account:
 - read
 - power

Environment:
  - read
  - write

Deployment:
  - read
  - write

Dag:
  - read
  - write

*/

locals {
  deployments = [
    {
      name = "deployment_one"
      dag_ids = [
        "sparkify_etl",
        "sparkify_analytics"
      ]
    }
  ]
}



module "terraform-airflow-deployment-aws-iam" {
  for_each = {for deployment in local.deployments: deployment.name => deployment}
  source = "./terraform-airflow-deployment-aws-iam"
  
  deployment_access_tags = {
      "deployment_name" = each.key
  }

  create_deployment_read_access_role = true
  deployment_read_access_role_name = "${each.key}-read-access-role"
  deployment_read_access_role_path = "/"
  deployment_read_access_role_permissions_boundary_arn = ""
  deployment_read_access_role_requires_mfa = false
  # deployment_read_access_role_tags = {
    
  # }
  
  # create_deployment_full_access_role = true

  create_dag_read_access_roles = true
  
  dag_read_access_roles_name = "${each.key}-read-access-role"
  dag_read_access_roles_path = "/"
  dag_read_access_roles_permissions_boundary_arn = ""
  dag_read_access_roles_requires_mfa = false
  dag_tag_key = "dag_id"
  dag_access_tags = {
    deployment_name = each.key
    dag_id = each.value.dag_ids
  }
}
