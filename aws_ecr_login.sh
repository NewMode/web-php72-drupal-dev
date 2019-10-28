#!/bin/bash

echo "Using https://hub.docker.com/r/mesosphere/aws-cli/ to login"
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "env: \$AWS_ACCESS_KEY_ID is expected for aws login"
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "env: \$AWS_SECRET_ACCESS_KEY is expected for aws login"
  exit 1
fi
if [ -z "$AWS_DEFAULT_REGION" ]; then
  echo "env: \$AWS_DEFAULT_REGION is expected for aws login"
  exit 1
fi

#AWS_ECR_LOGIN_CMD=`(aws ecr get-login --no-include-email --region ca-central-1)`
AWS_ECR_LOGIN_CMD=$(docker run --rm \
  -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"\
  -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
  -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
  -v "$(pwd):/project" \
  mesosphere/aws-cli \
  ecr get-login --no-include-email --region ca-central-1)

ret=$?
if [ $ret -ne 0 ]; then
  echo "Error: aws ecr login command exit code = $ret"
  exit $ret
fi

eval $AWS_ECR_LOGIN_CMD
#docker login -u $CR_USER -p $CR_PASS $CR_SERVER

ret=$?
if [ $ret -ne 0 ]; then
  echo "Error: docker login exit code = $ret"
  exit $ret
fi
