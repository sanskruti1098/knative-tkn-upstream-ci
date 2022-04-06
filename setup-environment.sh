#!/bin/bash

# **** This script runs on upstream knative ci server from ci-script which is stored in GCP. ****
# It sets up the k8s environment and updates the knative source for succesfully test run.

set -e

BASE_DIR=/opt/knative-upstream-ci
K8S_AUTOMN_DIR=${BASE_DIR}/k8s-ansible-automation
SSH_USER=root
SSH_HOST="cluster.ppc64le"
SSH_ARGS="-i /opt/cluster/knative-ssh -o MACs=hmac-sha2-256 -o StrictHostKeyChecking=no -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null"

# exit if CI_JOB is not set
if [ -z ${CI_JOB} ]
then
    echo "Missing CI_JOB variable"
    exit 1
fi

## Trigger k8s automation on remote power machines
echo "Creating k8s cluster...."
ssh ${SSH_ARGS} ${SSH_USER}@${SSH_HOST} ${K8S_AUTOMN_DIR}/create-cluster.sh &> /dev/null
if [ $? != 0 ]
then
    echo "Cluster creation failed."
    exit 1
fi

echo "Setting up access to k8s cluster...."
# copy access files
scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${K8S_AUTOMN_DIR}/share/* /tmp
# setup docker access
mkdir -p $HOME/.docker/
mv /tmp/config.json $HOME/.docker/
export SSL_CERT_FILE=/tmp/ssl.crt
# setup k8s access
mkdir -p $HOME/.kube/
mv /tmp/config $HOME/.kube/

echo 'Cluster created successfully'

## Fetch & run adjust.sh script to patch the source code with image replacements and other fixes
## Introducing CI_JOB var which can be used to fetch adjust script based on repo-tag
## $CI_JOB needs to be set in knative upstream job configurations
echo 'Patching source code with ppc64le specific changes....'
echo 'echo "No code ppc64le specific changes required."' > /tmp/adjust.sh
if [ ${CI_JOB} == "eventing-main" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/main/* /tmp/
elif [ ${CI_JOB} == "eventing-release-0.23" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/0.23/* /tmp/
fi
chmod +x /tmp/adjust.sh
. /tmp/adjust.sh