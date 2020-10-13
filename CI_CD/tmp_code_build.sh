aws codebuild create-project \
    --name ${name} \
    --description "Perform terraform apply with -auto-approve" \
    --source "{\"type\": \"GITHUB\",\"location\": \"https://github.com/marshall7m/sparkify_end_to_end.git\",
    \"buildspec\": \"CI_CD/cfg/buildspec_tf_apply_batch.yml\", \
    \"gitCloneDepth\": 1, \"gitSubmodulesConfig\": {\"fetchSubmodules\": false}}" \
    --artifacts "{\"type\": \"NO_ARTIFACTS\",\"overrideArtifactName\": false}" \
    --cache "{\"type\": \"NO_CACHE\"}" \
    --environment "{\"type\": \"LINUX_CONTAINER\", \"image\": \"aws/codebuild/standard:4.0\", \"computeType\": \"BUILD_GENERAL1_SMALL\",
    \"privilegedMode\": true,
    \"environmentVariables\": [{\"name\": \"TF_ROOT_DIR\",\"value\": \"deployment\",\"type\": \"PLAINTEXT\"},{
    \"name\": \"LIVE_BRANCHES\",\"value\": \"(dev, prod)\",\"type\": \"PLAINTEXT\"},{\"name\": \"TERRAFORM_VERSION\", 
    \"value\": \"0.12.28\",\"type\": \"PLAINTEXT\"},{\"name\": \"TF_IN_AUTOMATION\",\"value\": \"true\",\"type\": \"PLAINTEXT\"},
    {\"name\": \"TF_CLI_ARGS\",\"value\": \"-input=false\",\"type\": \"PLAINTEXT\"}]}" \
    --logs-config "{\"cloudWatchLogs\": {\"status\": \"ENABLED\"}, \"s3Logs\": {\"status\": \"ENABLED\",\"location\": \"private-sparkify/CI_CD/terraform_apply\",
    \"encryptionDisabled\": false}}" \
    --tags key="service",value="CI" key="version",value="0.0.1" key="project_id",value=${project_id} \
    key="client",value=${client} key="terraform",value="true" \
    --service-role ${service_role_arn} \
    --build-batch-config "{\"serviceRole\": \"${service_role_arn}\"}"