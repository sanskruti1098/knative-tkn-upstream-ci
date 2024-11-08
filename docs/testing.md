# Test New Jobs 

### Create job configurations

Refer [create_job](./create_job.md) to create job configs

### Prerequisites

- x86 Fedora VM with Kind installed.

### Create KinD cluster

Run the following command to create an x86 KinD cluster
```bash
kind create cluster --name=mkpod
```
    
### Setup secrets on the cluster

We require 3 secrets 
- `knative-ssh` key to access to the knative VSIs created.
- `IBM Cloud API key` key used to create/delete VSIs in IBM Cloud.
- `config.json` Needed by the cluster to access the IBM Container Registry.

Contact [Valen Mascarenhas](Valen.Mascarenhas@ibm.com)  or [Kumar Abhishek](Kumar.Abhishek2@ibm.com)  for manifest file 
 

### Clone the test-infra repo & export the necessary variables

```bash

git clone https://github.com/ppc64le-cloud/test-infra.git

cd test-infra

# Path to the main Prow configuration file containing all job definitions
Ex.
export CONFIG_PATH=$(pwd)/config/prow/config.yaml

# Path to the job configuration file for testing the Knative component in periodic jobs
Ex.
export JOB_CONFIG_PATH=$(pwd)/config/jobs/periodic/knative/operator/main/operator-main.gen.yaml

```

### Run prowjobs locally 


```bash

git git clone https://github.com/kubernetes-sigs/prow.git
cd prow/pkg

./pj-on-kind.sh <job-name>

```

### Check the pod logs of the prowjob running 


```bash

kubectl logs -f  <pod-name>

```

### Commit changes

Once the changes are tested, we can commit and create a PR to upstream the configurations.
