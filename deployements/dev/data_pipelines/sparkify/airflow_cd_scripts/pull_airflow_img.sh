sudo su - ec2-user

REPO_URL=$(aws ssm get-parameter --name $DEPLOYMENT_GROUP_NAME-ecr-repo-url)
IMG_TAG=$(aws ssm get-parameter --name $DEPLOYMENT_GROUP_NAME-ecr-img-tag)
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | python -c "import json,sys; print json.loads(sys.stdin.read())['region']")

export REPO_URL
export IMG_TAG

docker pull $repo_url:$img_tag