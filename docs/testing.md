# Test New Jobs 

### Create job configurations

Refer [create_job](./create_job.md) to create job configs

### Prerequisites

- Centos precreated vms at PowerVS. Refer infrastructure [document](infra.md).
- Access to GCP secret manager service. Refer GCP [doc](../gcp-secrets/README.md) for more details.
    
### Setup secrets on the local Fedora node

The secrets created on upstream server has following structure
- `knative-ssh` key to access to the knative cluster-pool node.
- `ci-script` script is used to connect to the knative cluster-pool node, make ppc64le specific changes and setup the environment for testing.
- `vm-script` Due to the increasing number of components, we moved from a single cluster to 2 clusters for running tests. This script is used to determine the available cluster and allocate it for testing purposes.

For testing purpose we need to create them manually. On upstream server they are added via GCP secret manager service. Details can be found in [gcp-secrets](../gcp-secrets) directory.
 
```bash
SECRET_DIR=/opt/cluster
mkdir -p ${SECRET_DIR}

cp <id_rsa for access> ${SECRET_DIR}/knative-ssh
cp <ci-script from gcp-secrets directory> ${SECRET_DIR}/ci-script
cp <vm-script from gcp-secrets directory> ${SECRET_DIR}/vm-script
```

### Generate prowjobs with mkpj for local testing

More info on mkpj can be found in [RTC Task 140140](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=140140).  
Make sure you are in test-infra source code directory

```bash
# value can be found out from generated configs
export JOB_NAME=ppc64le-e2e-tests_eventing_main_periodic
# file name which contains job configurations to test
export JOB_CONFIG_YAML=${PWD}/prow/jobs/generated/knative/eventing-main.gen.yaml

export CONFIG_YAML=${PWD}/prow/config.yaml
export JOB_YAML=/tmp/test-job

docker run -i --rm \
     -v "${PWD}:${PWD}" -v "${CONFIG_YAML}:${CONFIG_YAML}" -v "${JOB_CONFIG_YAML}:${JOB_CONFIG_YAML}" \
     -w "${PWD}" \
     gcr.io/k8s-prow/mkpj:v20220323-9b8611d021 \
     "--job=${JOB_NAME}" "--config-path=${CONFIG_YAML}" "--job-config-path=${JOB_CONFIG_YAML}" \
     > ${JOB_YAML}
```

### Run prowjobs locally using phaino

More info on phaino can be found in [RTC Task 140140](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=140140) or in official phaino [docs](https://github.com/kubernetes/test-infra/tree/master/prow/cmd/phaino).

```bash
export TEST_TOOLS_SRC=$HOME/test-infra-prow
cd $TEST_TOOLS_SRC
git clone https://github.com/kubernetes/test-infra.git $TEST_TOOLS_SRC
cd $TEST_TOOLS_SRC

# clone the source code of component under test
git clone https://github.com/knative/eventing.git /tmp/eventing

# ensure that secret files are present under /opt/cluster directory

#file path of generated prowjob config
JOB_FILE_PATH=/tmp/test-job 

go run ./prow/cmd/phaino $JOB_FILE_PATH --skip-volume-mounts=test-account --privileged

# input to phaino
/opt/cluster
/tmp/eventing
```
### Debugging
Refer [debug_job](debug-environment-issues.md) for the debugging the failing jobs.

**TIP**: To debug or resolve issues we can add a sleep statement into job configrations and exec into it the container.

### Commit changes

Once the changes are tested, we can commit and create a PR to upstream the configurations.

```bash 
export KNATIVE_TEST_SRC=$HOME/infra
cd KNATIVE_TEST_SRC
git status
git add .
git commit -s -m "Add ppc64le nightly prow job for <component>"
```
