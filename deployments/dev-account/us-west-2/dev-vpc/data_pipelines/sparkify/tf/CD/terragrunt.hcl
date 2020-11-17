include {
  path = find_in_parent_folders()
}

terraform {
    source = "github.com/marshall7m/tf_modules/terraform-aws-cd"
}


inputs = {
    
    create_ecr_repo = true
    ecr_base_domain = "data-pipelines"
    ecr_repo_url_to_ssm = true

    create_cd_app = true
    cd_app_name = "data-pipelines"
    cd_app_compute_platform = "Server"

    create_cd_config = true
    cd_config_name = "data-pipelines"
    cd_config_minimum_healthy_hosts = {
        type  = "HOST_COUNT"
        value = 2
    }

    create_cd_group = true
    cd_group_name = "sparkify-analytics"
    cd_group_deployment_style = {
        deployment_option = "WITHOUT_TRAFFIC_CONTROL"
        deployment_type = "IN_PLACE"
    }
    cd_group_auto_rollback_configuration = {
        enabled = true
        events  = ["DEPLOYMENT_STOP_ON_ALARM"]
    }
}