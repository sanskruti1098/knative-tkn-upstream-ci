#!/bin/bash

SCRIPT_LOCK="/tmp/.k8s.lock"
CLUSTER_POOL_DIR="/root/cluster-pool/pool/k8s"

# stdout is used to print kubeconfig file
# therefore redirect the status output to error stream to keep it clean
function echo_status(){
    echo "$@" > /dev/stderr
}

function help(){
    cat <<-EOF > /dev/stderr

Script to acquire/release a OpenShift cluster from pool of clusters in PowerVS

Usage:
  k8s.sh [command] [<args> [<value>]]

Available commands:
  acquire         Acquire a k8s cluster from pool
  release         Release a k8s cluster
  help            Display this information

Where <args> for command:
  acquire
    --version | -v        Kubernetes cluster version (optional)

  release
    --name    | -n        Kubernetes cluster name (required)

EOF
    exit 0
}

# a cluster in pool is avaiable for use if it's state directory doesn't contain ACQUIRED file
# Critical section, should run with lock.
# https://jdimpson.livejournal.com/5685.html?
function acquire_cluster(){

    exec 8>$SCRIPT_LOCK

    if flock --timeout 60 -x 8; then
        
        local acquired=false
        local cluster_name=""

        for dir in $(ls ${CLUSTER_POOL_DIR}); do
           
            local cluster_dir="${CLUSTER_POOL_DIR}/${dir}"
            local state_file="${cluster_dir}/.state/ACQUIRED"
            local kubeconfig_file="${cluster_dir}/kubeconfig"
            local version_file="${cluster_dir}/.state/VERSION"

            [ -d "${cluster_dir}" ] || continue # if not a directory, skip

            # TODO: add check for tagged cluster(clusters specially created for certain jobs)
            if [[ ! -f $state_file && -f $version_file && -f $kubeconfig_file ]]; then
              
                date > $state_file
                acquired=true
                cluster_name=$dir
                break
            fi
        done

        if $acquired; then
            echo "$cluster_name"
            exit 0
        else
            exit 1
        fi

    else
        echo_status "Couldn't acquire lock. Please try agian.";
    fi

}

# to release a custer, add a RELEASED file in cluster's state directory
# ensure you provide cluster version if non default version cluster was acquired
function release_cluster(){
    echo_status "Releasing cluster...."

    if [[ -z $CLUSTER_NAME ]]; then
        echo_status 'Please provide cluster name.'
        exit 1
    fi

    local cluster_dir="${CLUSTER_POOL_DIR}/${CLUSTER_NAME}"
    if [[ -d  $cluster_dir ]]; then
        rm -rf $cluster_dir/.state/ACQUIRED
        local state_file=$cluster_dir/.state/RELEASED
        date > $state_file
        if [[ $? != 0 ]]; then
            echo_status "Something went wrong. Please try again."
            exit 1
        fi
        echo_status "$CLUSTER_NAME cluster released."
    else
        echo_status "Couldn't release the cluster. Cluster not found."
        exit 1
    fi
}

function main(){
    # Parse commands and arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            "--version"|"-v")
                shift
                version="$1"
            ;;
            "--name"|"-n")
                shift
                name="$1"
            ;;
            "acquire")
                action="acquire"
            ;;
            "release")
                action="release"
            ;;
            "help")
                help
            ;;
        esac
        shift
    done

    [[ -z "$action" ]] && help

    CLUSTER_NAME="$name"

    case "$action" in
        "acquire")    acquire_cluster;;
        "release")    release_cluster;;
        *)            echo_status "Invalid usage!";;
    esac
}

