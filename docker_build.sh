#!/bin/bash

# Gitlab uses $CI_COMMIT_SHA, CircleCI uses $CIRCLE_SHA1

if [ -z "$CIRCLE_SHA1" ]; then
  echo "env: \$CIRCLE_SHA1 is expected (the commit hash from repo)"
  exit 1
else
  echo "Getting CIRCLE_SHA1 from env: $CIRCLE_SHA1"
fi

CR_SERVER=144447806810.dkr.ecr.ca-central-1.amazonaws.com
IMAGE=newmode/web-php72-drupal-dev

docker build --no-cache --pull -t $IMAGE .
# Switch to this build command on local if you need faster rebuild.
#docker build --pull -t $IMAGE .

ret=$?
if [ $ret -ne 0 ]; then
  echo "Error: docker build exit code = $ret"
  exit $ret
fi

./aws_ecr_login.sh

docker tag $IMAGE:latest $CR_SERVER/$IMAGE:latest

docker push $CR_SERVER/$IMAGE:latest
ret=$?
if [ $ret -ne 0 ]; then
  echo "Error: docker push exit code = $ret"
  exit $ret
fi

# tag and push using specific tag
if [ "$CIRCLE_SHA1" != "" ]; then
    # tagging & pushing
    docker tag $CR_SERVER/$IMAGE:latest $CR_SERVER/$IMAGE:$CIRCLE_SHA1
    docker push $CR_SERVER/$IMAGE:$CIRCLE_SHA1

    ret=$?
    if [ $ret -ne 0 ]; then
      echo "Error: docker push tag $CIRCLE_SHA1 exit code = $ret"
      exit $ret
    fi

fi
