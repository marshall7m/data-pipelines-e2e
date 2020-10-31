module "airflow_deployment_CI_CD" {
    source = "../../../../../../terraform-aws-airflow-ci-cd"
    
    aws_caller_user_id = get_aws_account_id()
    github_repo_url = "https://github.com/marshall7m/sparkify_end_to_end.git"
    
    private_bucket_name = local.private_bucket
    tf_state_bucket_name = local.private_bucket
    region = "us-west-2"

    deployment_directory = "deployments/dev/data_pipelines/sparkify/"
    airflow_deployment_directory = "deployments/dev/data_pipelines/sparkify/src/"
    
    codebuild_deployment_directory_trigger = true
    create_codebuild_terraform_plan_project = true
    create_codebuild_terraform_apply_project = true
    create_codebuild_iam_role = true

    deployment_group_name = "${var.env}-${basename(dirname(path.cwd))}"
    ec2_tag_set_list = [
        {
            environment = var.env
        },
        {
            deployment_group_name = "${var.env}-${basename(dirname(path.cwd))}"
        }
    ]
    ec2_tag_filters = {
        environment = var.env
        deployment_group_name = "${var.env}-${basename(dirname(path.cwd))}"
    }
    
    ecr_base_domain = "${var.org}.${var.region}"
    
    terraform_version = "0.12.28"
    terragrunt_version = "0.25.4"

    tags = {
        "terraform"     = "true"
        "terraform_path" = "${local.project_id}/CI_CD/"
        "client" = "${local.client}"
        "project_id" = "${local.project_id}"
    }
}