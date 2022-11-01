#!/bin/bash

# **** This script runs on upstream knative ci server from ci-script which is stored in GCP. ****
# It sets up the k8s environment and updates the knative source for succesfully test run.


#--- Common Functions ---
create_registry_secrets_in_serving(){
    kubectl create ns knative-serving
    kubectl -n knative-serving create secret generic registry-creds --from-file=config.json=$HOME/.docker/config.json
    kubectl -n knative-serving create secret generic registry-certs --from-file=ssl.crt=/tmp/ssl.crt
}

install_contour(){
    # TODO: remove yq dependency
    wget https://github.com/mikefarah/yq/releases/download/v4.25.3/yq_linux_amd64 -P /tmp
    chmod +x /tmp/yq_linux_amd64
	
    echo "Contour is being installed..."
    # TODO: document envoy image creation process
    envoy_replacement=registry.ppc64le/contour:v1.19.1
    ISTIO_RELEASE=knative-v1.0.0
    
     # install istio-crds
    #kubectl apply -f https://github.com/knative-sandbox/net-istio/releases/download/${ISTIO_RELEASE}/istio.yaml 2> /dev/null || true
    curl --connect-timeout 10 --retry 5 -sL https://github.com/knative-sandbox/net-istio/releases/download/${ISTIO_RELEASE}/istio.yaml | \
    /tmp/yq_linux_amd64 '. | select(.kind == "CustomResourceDefinition"), select(.kind == "Namespace")' | kubectl apply -f -
    
    # install contour
    curl --connect-timeout 10 --retry 5 -sL https://raw.githubusercontent.com/knative/serving/release-1.1/third_party/contour-latest/contour.yaml | \
    sed 's!\(image: \).*docker.io.*!\1'$envoy_replacement'!g' | kubectl apply -f -
    kubectl apply -f https://raw.githubusercontent.com/knative/serving/main/third_party/contour-latest/net-contour.yaml
    echo "Waiting until all pods under contour-external are ready..."
    kubectl wait --timeout=5m pod --for=condition=Ready -n contour-external -l '!job-name'
}
#------------------------


# TODO: Find root cause for below
# Sometimes job fails with no host found error. Looks like /etc/hosts patching done in ci-script
# is not retained for some reason. Adding a fix for such situation. 
# Public IP of bastion node in PowerVS
BASTION_IP="169.48.22.244"
# add host entires
echo "${BASTION_IP} cluster.ppc64le registry.ppc64le ppc64le" >> /etc/hosts

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
ssh ${SSH_ARGS} ${SSH_USER}@${SSH_HOST} ${K8S_AUTOMN_DIR}/create-cluster.sh
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

# TODO: merge with patching conditional code below? 
if [[ ${CI_JOB} =~ client-* ]]
then
    create_registry_secrets_in_serving &> /dev/null
    install_contour &> /dev/null
elif [[ ${CI_JOB} =~ operator-* ]]
then
    install_contour &> /dev/null
elif [[ ${CI_JOB} =~ eventing-* ]]
then
    echo ""
fi

echo 'Cluster created successfully'

## Fetch & run adjust.sh script to patch the source code with image replacements and other fixes
## Introducing CI_JOB var which can be used to fetch adjust script based on repo-tag
## $CI_JOB needs to be set in knative upstream job configurations
echo 'Patching source code with ppc64le specific changes....'
echo 'echo "No ppc64le specific code changes required."' > /tmp/adjust.sh
if [ ${CI_JOB} == "eventing-main" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/main/* /tmp/
elif [ ${CI_JOB} == "eventing_rekt-main" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/main/* /tmp/
elif [ ${CI_JOB} == "eventing_rekt-1.7" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/main/* /tmp/
elif [ ${CI_JOB} == "eventing_rekt-1.8" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/main/* /tmp/
elif [ ${CI_JOB} == "eventing-release-1.4" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/release-1.4/* /tmp/
elif [ ${CI_JOB} == "eventing-release-1.5" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/release-1.5/* /tmp/
elif [ ${CI_JOB} == "eventing-release-1.6" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/release-1.6/* /tmp/
elif [ ${CI_JOB} == "eventing-release-1.7" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/release-1.7/* /tmp/
elif [ ${CI_JOB} == "eventing-release-1.8" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/eventing/release-1.8/* /tmp/
elif [ ${CI_JOB} == "client-main" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/client/main/* /tmp/
elif [ ${CI_JOB} == "client-release-1.6" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/client/release-1.6/* /tmp/
elif [ ${CI_JOB} == "client-release-1.7" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/client/release-1.7/* /tmp/
elif [ ${CI_JOB} == "client-release-1.8" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/client/release-1.8/* /tmp/
elif [ ${CI_JOB} == "operator-main" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/operator/main/* /tmp/
elif [ ${CI_JOB} == "operator-release-1.6" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/operator/release-1.6/* /tmp/
elif [ ${CI_JOB} == "operator-release-1.7" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/operator/release-1.7/* /tmp/
elif [ ${CI_JOB} == "operator-release-1.8" ]
then
    scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/operator/release-1.8/* /tmp/
fi
chmod +x /tmp/adjust.sh
. /tmp/adjust.sh