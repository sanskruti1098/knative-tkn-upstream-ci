## Create job configuration

The process for adding a new job is to
1. write config in corresponding yaml file in [knative](https://github.com/knative/infra/tree/main/prow/jobs_config/knative) or [](https://github.com/knative/infra/tree/main/prow/jobs_config/knative-extensions) directory based on the knative component under test.
2. run [generate-configs.sh](https://github.com/knative/infra/blob/main/hack/generate-configs.sh) which will create the required configuration in [generated](https://github.com/knative/infra/tree/main/prow/jobs/generated) directory.

Refer PR [#117](https://github.com/knative/infra/pull/117) for more details.

- Setup env var

  ```bash
  export KNATIVE_TEST_SRC=$HOME/infra
  ```
    
- Clone your fork of [knative/infra](https://github.com/knative/infra)

  ```bash
  git clone https://github.com/<org-name>/test-infra.git $KNATIVE_TEST_SRC
  cd $KNATIVE_TEST_SRC
  git checkout -b <branch-name>
  ```
    
- Add new configurations in corresponding yaml files in  `prow/jobs_config/knative/`. Refer [ppc64le PRs](https://github.com/knative/infra/pulls?q=ppc64le) for time and other details. 
Below configurations are for eventing main branch tests on power which are added to `prow/jobs_config/knative/eventing.yaml` file.
  ```bash
  - name: ppc64le-e2e-tests
    cron: 45 2 * * *
    types: [periodic]
    requirements: [ppc64le]
    command: [runner.sh]
    args:
      - bash
      - -c
      - |
        server_vm="$(sh /opt/cluster/vm-script)"
        source /opt/cluster/ci-script "${CI_JOB}" "${server_vm}"
        ./test/e2e-tests.sh --run-tests
    env:
      - name: SYSTEM_NAMESPACE
        value: knative-eventing
      - name: SCALE_CHAOSDUCK_TO_ZERO
        value: "1"
      - name: CI_JOB
        value: "eventing-main"
  ```
  
  In above config, 
  
  ```bash
        server_vm="$(sh /opt/cluster/vm-script)"
        source /opt/cluster/ci-script "${CI_JOB}" "${server_vm}"
        ./test/e2e-tests.sh --run-tests
  ```
  
  will remain same for most of the jobs. 
  
  ```bash
  - name: CI_JOB
    value: "eventing-main"
  ```
  
  will change based on component and version to be tested. `$CI_JOB` is used in `setup-environment.sh` script to fetch correct adjustment script.

- Run `./hack/generate-configs.sh` to generate prow configs

  ```bash
  ./hack/generate-configs.sh
  ```
  
  This will automatically parse newly added configs and create prow job configurations based on config defined in[.base.yaml](https://github.com/knative/infra/blob/a6bc64d2da9f4055041b4f50925e0a405e4c9e60/prow/jobs_config/.base.yaml#L223).  
  For instance: `requirements: [ppc64le]` will expand configurations to include env vars and secrets defined in under `ppc64le` key in `.base.yaml`.

## Modify the adjustment scripts

Refer [adjustment-scripts](https://github.ibm.com/ppc64le-automation/knative-upstream-ci/blob/v-dev/docs/adjustment-scripts.md) to make ppc64le specific changes in `/opt/knative-upstream-ci` folder on the cluster-pool node