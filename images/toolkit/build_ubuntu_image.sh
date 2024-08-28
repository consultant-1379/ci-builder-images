#!/bin/bash
#############################################################################################################################
# Script
#  Builds a container consisting of stable versions of kubectl,helm, helmfile, yq, jq, vcluster, vcerts...
#  This image can be used in ruleset as docker-image to run common shell processes
#  This is useful because sometimes we want to use newer versions of these tools than the one supplied by ADP
#  For example, ADP gives yq version 2.x but we want to use 4.x which has lot of improvements
#############################################################################################################################
#  WARNING:  It is not advised to use this image to create deliverables. For those purposes use the official ADP images
#############################################################################################################################

set -e

case "$(uname -s)" in
Darwin*) SCRIPT=$(greadlink -f $0) ;;
*) SCRIPT=$(readlink -f $0) ;;
esac

# Absolute path this script is in. /home/user/bin
BASEDIR=$(dirname $SCRIPT)
MODULEROOT=$(dirname $BASEDIR)
REPOROOT=$(dirname $MODULEROOT)

echo "Base image is  ${BASE_IMAGE}"

RELEASE_TAG=$(date +%Y%m%d)

IMAGE=armdocker.rnd.ericsson.se/proj-mxe-ci-internal/ci-toolkit:${RELEASE_TAG}
IMAGE_LATEST=armdocker.rnd.ericsson.se/proj-mxe-ci-internal/ci-toolkit:latest


DOCKER_BUILDKIT=1 docker build --no-cache -t ${IMAGE} -t ${IMAGE_LATEST} \
    -f ${BASEDIR}/Dockerfile ${BASEDIR} --progress plain
buildStatus=$?

if [[ $buildStatus == 0 ]]; then
    docker push ${IMAGE}
    docker push ${IMAGE_LATEST}
else
    echo "Docker build failed"
fi
