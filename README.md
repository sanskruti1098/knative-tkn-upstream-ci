# Knative Upstream CI
Automation, configurations, scripts &amp; documentation on Knative Upstream CI on Power.

### Test flow 

![Test Flow](./docs/data/test-flow-arch.png)

Explaination: https://ibm.box.com/s/jadfn2jsh4ans1pbp167g3ctbxn0sa0j

### Prerequisites

- RHEL/Centos precreated vms at PowerVS. Refer infrastructure [document](./docs/infra.md).
- Access to GCP secret manager service. Refer GCP [doc](./gcp-secrets/README.md) for more details.

### Setup automation

Ensure ssh key is added onto bastion to access all nodes and ansible is installed onto bastion.

- Clone the repo in `/opt/` directory on bastion. 
    Cloning the directory at any other loaction will require update in `$BASE_DIR` var in `setup-environment.sh` and in upstream test configurations in [knative/test-infra](https://github.com/knative/test-infra).
    ```bash
    cd /opt
    git clone https://github.ibm.com/ppc64le-automation/knative-upstream-ci
    cd knative-upstream-ci
    
    # clone k8s automation submodule
    git submodule init
    git submodule update
    ```

- Setup the k8s automation
    - Create `k8s-ansible-automation/hosts.yml` with node details. 
        Refer [k8s-ansible-automation/hosts-sample.yml](./k8s-ansible-automation/hosts-sample.yml) file.
    - Create `k8s-ansible-automation/env.yml` with other details. 
        Refer [k8s-ansible-automation/env-sample.yml](./k8s-ansible-automation/env-sample.yml) file.

- Trigger a test run to create k8s cluster

  ```bash
  ./k8s-ansible-automation/create-cluster.sh
  ```
  <!--TODO: update automation to install kubectl on bastion-->
  ```bash
  $ kubectl get nodes
  NAME              STATUS   ROLES                  AGE     VERSION
  knative-master    Ready    control-plane,master   9m28s   v1.22.0
  knative-worker1   Ready    <none>                 9m6s    v1.22.0
  knative-worker2   Ready    <none>                 9m6s    v1.22.0
  ```

### Configure secrets in GCP

Add/update cluster details on upstream server via GCP. Refer [gcp-secrets](./gcp-secrets/) directory for more details.

### Create upstream jobs 

Refer [adjustment-scripts.md](./docs/adjustment-scripts.md) to add new `adjust.sh` script and [testing.md](./docs/testing.md) to add & test the job configurations.