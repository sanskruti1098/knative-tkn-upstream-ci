# Create & Test New Jobs

### Create job configurations

The process for adding a new job is to
1. write config in corresponding yaml file in [knative](https://github.com/knative/test-infra/tree/74007720aeb71bebe917748f1e14c50ede704bff/prow/jobs_config/knative) directory based on the knative component under test.
2. run [generate-configs.sh](https://github.com/knative/test-infra/blob/74007720aeb71bebe917748f1e14c50ede704bff/hack/generate-configs.sh) which will creates required configuration in [generated/knative](https://github.com/knative/test-infra/tree/74007720aeb71bebe917748f1e14c50ede704bff/prow/jobs/generated/knative) directory.

Refer [RTC Task 148175](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=148175) & PR [#3255](https://github.com/knative/test-infra/pull/3255) for more details.

- Setup env var

  ```bash
  export KNATIVE_TEST_SRC=$HOME/test-infra
  ```
    
- Clone your fork of [knative/test-infra](https://github.com/knative/test-infra)

  ```bash
  git clone https://github.com/Siddhesh-Ghadi/test-infra.git $KNATIVE_TEST_SRC
  cd $KNATIVE_TEST_SRC
  git checkout -b new-branch
  ```
    
- Add new configurations in corresponding yaml files in  `prow/jobs_config/knative/`. Refer [s390x PRs](https://github.com/knative/test-infra/pulls?q=s390x) for time and other details. 
Below configurations are for eventing main branch tests on power which are added to `prow/jobs_config/knative/eventing.yaml` file.
  ```bash
  - name: ppc64le-e2e-tests
    cron: 0 7 * * *
    types: [periodic]
    requirements: [ppc64le]
    command: [runner.sh]
    args:
      - bash
      - -c
      - |
        cat /opt/cluster/ci-script > /tmp/connect.sh
        chmod +x /tmp/connect.sh
        . /tmp/connect.sh ${CI_JOB}
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
  cat /opt/cluster/ci-script > /tmp/connect.sh
  chmod +x /tmp/connect.sh
  . /tmp/connect.sh ${CI_JOB}
  ```
  
  will remain same for most of the jobs. 
  
  ```bash
  - name: CI_JOB
    value: "eventing-main"
  ```
  
  will change based on component and version to be tested. `$CI_JOB` is usedin `setup-environment.sh` script to fetch correct adjustment script.

- Changes to avoid random sync  
  The jobs randomly reschedule to avoid load on prow server however this can mess up our timely jobs hence we need to prevent it from happening by adding a exclusion in [tools/release-jobs-syncer/pkg/jobs_sync.go](https://github.com/knative/test-infra/blob/74007720aeb71bebe917748f1e14c50ede704bff/tools/release-jobs-syncer/pkg/jobs_sync.go#L45)

  ```diff
  --- a/tools/release-jobs-syncer/pkg/jobs_sync.go
  +++ b/tools/release-jobs-syncer/pkg/jobs_sync.go
  @@ -44,7 +44,7 @@ const (
   // the load with Prow.
   var extraPeriodicProwJobsToSync map[string]sets.String = map[string]sets.String{
          "knative/serving":  sets.NewString("s390x-kourier-tests", "s390x-contour-tests"),
  -       "knative/eventing": sets.NewString("s390x-e2e-tests", "s390x-e2e-reconciler-tests"),
  +       "knative/eventing": sets.NewString("s390x-e2e-tests", "s390x-e2e-reconciler-tests", "ppc64le-e2e-tests"),
          "knative/client":   sets.NewString("s390x-e2e-tests"),
          "knative/operator": sets.NewString("s390x-e2e-tests"),
   }
  ```

- Run `./hack/generate-configs.sh` to generate prow configs

  ```bash
  ./hack/generate-configs.sh
  ```
  
  This will automatically parse newly added configs and create prow job configurations based on config defined in[.base.yaml](https://github.com/knative/test-infra/blob/74007720aeb71bebe917748f1e14c50ede704bff/prow/jobs_config/.base.yaml#L119).  
  For instance: `requirements: [ppc64le]` will expand configurations to include env vars and secrets defined in under `ppc64le` key in `.base.yaml`.
    
- Results of `./hack/generate-configs.sh`

  ```diff
  --- a/prow/jobs/generated/knative/eventing-main.gen.yaml
  +++ b/prow/jobs/generated/knative/eventing-main.gen.yaml
  @@ -206,6 +206,77 @@ periodics:
         secret:
           defaultMode: 384
           secretName: s390x-cluster1
  +- annotations:
  +    testgrid-dashboards: eventing
  +    testgrid-tab-name: ppc64le-e2e-tests
  +  cluster: build-knative
  +  cron: 0 7 * * *
  +  decorate: true
  +  extra_refs:
  +  - base_ref: main
  +    org: knative
  +    path_alias: knative.dev/eventing
  +    repo: eventing
  +  name: ppc64le-e2e-tests_eventing_main_periodic
  +  spec:
  +    containers:
  +    - args:
  +      - bash
  +      - -c
  +      - |
  +        cat /opt/cluster/ci-script > /tmp/connect.sh
  +        chmod +x /tmp/connect.sh
  +        . /tmp/connect.sh ${CI_JOB}
  +        ./test/e2e-tests.sh --run-tests
  +      command:
  +      - runner.sh
  +      env:
  +      - name: SYSTEM_NAMESPACE
  +        value: knative-eventing
  +      - name: SCALE_CHAOSDUCK_TO_ZERO
  +        value: "1"
  +      - name: CI_JOB
  +        value: eventing-main
  +      - name: E2E_CLUSTER_REGION
  +        value: us-central1
  +      - name: GOOGLE_APPLICATION_CREDENTIALS
  +        value: /etc/test-account/service-account.json
  +      - name: KO_FLAGS
  +        value: --platform=linux/ppc64le
  +      - name: PLATFORM
  +        value: linux/ppc64le
  +      - name: KO_DOCKER_REPO
  +        value: registry.ppc64le
  +      - name: DISABLE_MD_LINTING
  +        value: "1"
  +      - name: KUBECONFIG
  +        value: /root/.kube/config
  +      image: gcr.io/knative-tests/test-infra/prow-tests:v20220405-5a6cdbac
  +      name: ""
  +      resources:
  +        limits:
  +          memory: 16Gi
  +        requests:
  +          memory: 12Gi
  +      securityContext:
  +        privileged: true
  +      volumeMounts:
  +      - mountPath: /etc/test-account
  +        name: test-account
  +        readOnly: true
  +      - mountPath: /opt/cluster
  +        name: ppc64le-cluster
  +        readOnly: true
  +    nodeSelector:
  +      type: testing
  +    volumes:
  +    - name: test-account
  +      secret:
  +        secretName: test-account
  +    - name: ppc64le-cluster
  +      secret:
  +        defaultMode: 384
  +        secretName: ppc64le-cluster
   - annotations:
       testgrid-dashboards: eventing
       testgrid-tab-name: nightly
  ```

### Setup secrets on x86 node

The secrets created on upstream server has following structure
- `knative-ssh` for ssh access to ppc64le hardware.
- `ci-script` script to setup host entries and fetch cluster creation script.

For test purpose we need to create them manually. On upstream server they are added via GCP secret manager service. Details can be found in [gcp-secrets](../gcp-secrets/) directory.
 
```bash
SECRET_DIR=/opt/cluster
mkdir -p ${SECRET_DIR}

cp <id_rsa for access> ${SECRET_DIR}/knative-ssh
cp <ci-script from gcp-secrets directory> ${SECRET_DIR}/ci-script
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

# Install bazel: https://bazel.build/install/ubuntu
bazel run //prow/cmd/phaino -- $JOB_FILE_PATH \
	--skip-volume-mounts=test-account \
  --privileged

# input to phaino
/opt/cluster
/tmp/eventing
```

**TIP**: To debug or resolve issues we can add a sleep statement into job configrations and exec into it the container.

### Commit changes

Once the changes are tested, we can commit and create a PR to upstream the configurations.

```bash 
export KNATIVE_TEST_SRC=$HOME/test-infra
cd KNATIVE_TEST_SRC
git status
git add .
git commit -s -m "Add ppc64le nightly prow job for <component>"
```
