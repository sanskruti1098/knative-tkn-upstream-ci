# Create & Test New Jobs

### Create job configurations

The process for adding a new job is to
1. write config in [config_knative.yaml](https://github.com/knative/test-infra/blob/main/prow/config_knative.yaml)
2. run [update-codegen.sh](https://github.com/knative/test-infra/blob/main/hack/update-codegen.sh) which will creates required configuration in [jobs/config.yaml](https://github.com/knative/test-infra/blob/main/prow/jobs/config.yaml)  and [testgrid/testgrid.yaml](https://github.com/knative/test-infra/blob/main/config/prow/testgrid/testgrid.yaml)

Refer [RTC Task 140142](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=140142) for more details.

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
    
- Add new configurations in `prow/config_knative.yaml`. Refer [s390x PRs](https://github.com/knative/test-infra/pulls?q=s390x) for time and other details. Make sure you add `ppc64le` configurations below corresponding s390x jobs.

    ```bash
      - custom-job: ppc64le-e2e-tests
        cron: 0 7 * * *
        command:
        - bash
        args:
        - -c
        - >-
          server_addr=$(cat /opt/cluster/config) &&
          scp -i /opt/cluster/knative.pem -o MACs=hmac-sha2-256 -o StrictHostKeyChecking=no -oLogLevel=ERROR -o UserKnownHostsFile=/dev/null root@${server_addr}:/opt/knative-upstream-ci/setup-environment.sh /tmp &&
          . /tmp/setup-environment.sh ${server_addr} &&
          ./test/e2e-tests.sh --run-tests
        env-vars:
        - DISABLE_MD_LINTING="1"
        - KO_FLAGS="--platform=linux/ppc64le"
        - DEPLOY_KNATIVE_MONITORING="0"
        - SYSTEM_NAMESPACE="knative-eventing"
        - PLATFORM="linux/ppc64le"
        - KUBECONFIG="/root/.kube/config"
        - SCALE_CHAOSDUCK_TO_ZERO="1"
        - JOB="eventing-main"
        external_cluster:
          secret: ppc64le-cluster
    ```
    
    In above config, 
    
    ```bash
    >-
    server_addr=$(cat /opt/cluster/config) &&
    scp -i /opt/cluster/knative.pem -o MACs=hmac-sha2-256 -o StrictHostKeyChecking=no -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null root@${server_addr}:/opt/knative-upstream-ci/setup-environment.sh /tmp &&
    . /tmp/setup-environment.sh ${server_addr}
    ```
    
    will remain same for most of the jobs. 
    
    ```bash
    - JOB="eventing-main"
    ```
    
    will change based on component and version to be tested. `$JOB` is used in `setup-environment.sh` script to fetch correct adjustment script.
    
    ```bash
    external_cluster:
        secret: ppc64le-cluster
    ```
    
    is present on upstream server which contains access details of remote ppc64le machine. Refer [Setup secrets on x86 node](#setup-secrets-on-x86-node) section for more details.
    
- Run `./hack/update-codegen.sh` to generate prow configs

    ```bash
    ./hack/update-codegen.sh
    ```
    
    This will automaticlly parse newly added configs and create prow job configurations based on keys defined in [config-generator](https://github.com/knative/test-infra/blob/main/tools/config-generator/main.go).  
    For example: `external_cluster` custom key is used to add `private key`, `ip address file` and a `secret env var` into the configuration. The expansion for this key was added by Z in [config-generator/main.go](https://github.com/knative/test-infra/blob/ac80d58b8c1cbca65b549c8c3723299505933668/tools/config-generator/main.go#L345-L361) file. So if we decide to use any new custom keys we need to add their corresponding expansions.
    
- Results of `update-codegen.sh`

    ```diff
    diff --git a/config/prow/testgrid/testgrid.yaml b/config/prow/testgrid/testgrid.yaml
    index 7eafbd33..8527e402 100644
    --- a/config/prow/testgrid/testgrid.yaml
    +++ b/config/prow/testgrid/testgrid.yaml
    @@ -152,6 +152,12 @@ test_groups:
     - name: ci-knative-eventing-s390x-e2e-tests
       gcs_prefix: knative-prow/logs/ci-knative-eventing-s390x-e2e-tests
       alert_stale_results_hours: 3
    +- name: ci-knative-eventing-ppc64le-e2e-tests
    +  gcs_prefix: knative-prow/logs/ci-knative-eventing-ppc64le-e2e-tests
    +  alert_stale_results_hours: 3
    +- name: ci-knative-eventing-test-coverage
    +  gcs_prefix: knative-prow/logs/ci-knative-eventing-go-coverage
    +  short_text_metric: "coverage"
     - name: ci-knative-pkg-continuous
       gcs_prefix: knative-prow/logs/ci-knative-pkg-continuous
       alert_stale_results_hours: 3
    @@ -228,9 +234,6 @@ test_groups:
     - name: ci-knative-eventing-0.26-s390x-e2e-tests
       gcs_prefix: knative-prow/logs/ci-knative-eventing-0.26-s390x-e2e-tests
       alert_stale_results_hours: 3
    -- name: ci-knative-eventing-0.26-test-coverage
    -  gcs_prefix: knative-prow/logs/ci-knative-eventing-0.26-go-coverage
    -  short_text_metric: "coverage"
     - name: ci-knative-operator-0.26-continuous
       gcs_prefix: knative-prow/logs/ci-knative-operator-0.26-continuous
       alert_options:
    @@ -1656,6 +1659,12 @@ dashboards:
       - name: s390x-e2e-tests
         test_group_name: ci-knative-eventing-s390x-e2e-tests
         base_options: "sort-by-name="
    +  - name: ppc64le-e2e-tests
    +    test_group_name: ci-knative-eventing-ppc64le-e2e-tests
    +    base_options: "sort-by-name="
    +  - name: coverage
    +    test_group_name: ci-knative-eventing-test-coverage
    +    base_options: "exclude-filter-by-regex=Overall$&group-by-directory=&expand-groups=&sort-by-name="
     - name: pkg
       dashboard_tab:
       - name: continuous
    @@ -2558,12 +2567,6 @@ dashboards:
         alert_options:
           alert_mail_to_addresses: "serverless-engprod-sea@google.com"
         num_failures_to_alert: 3
    -  - name: eventing-test-coverage
    -    test_group_name: ci-knative-eventing-0.26-test-coverage
    -    base_options: "sort-by-name="
    -    alert_options:
    -      alert_mail_to_addresses: "serverless-engprod-sea@google.com"
    -    num_failures_to_alert: 3
       - name: operator-continuous
         test_group_name: ci-knative-operator-0.26-continuous
         base_options: "sort-by-name="
  
    diff --git a/prow/jobs/config.yaml b/prow/jobs/config.yaml
    index 9b63a166..f7de309d 100644
    --- a/prow/jobs/config.yaml
    +++ b/prow/jobs/config.yaml
    @@ -13216,6 +13216,73 @@ periodics:
         - name: test-account
           secret:
             secretName: test-account
    +- cron: "0 7 * * *"
    +  name: ci-knative-eventing-ppc64le-e2e-tests
    +  agent: kubernetes
    +  decorate: true
    +  decoration_config:
    +    timeout: 120m
    +  cluster: "build-knative"
    +  extra_refs:
    +  - org: knative
    +    repo: eventing
    +    path_alias: knative.dev/eventing
    +    base_ref: main
    +  annotations:
    +    testgrid-dashboards: eventing
    +    testgrid-tab-name: ppc64le-e2e-tests
    +    testgrid-alert-stale-results-hours: "3"
    +  spec:
    +    containers:
    +    - image: gcr.io/knative-tests/test-infra/prow-tests:stable
    +      imagePullPolicy: Always
    +      command:
    +      - runner.sh
    +      args:
    +      - "bash"
    +      - "-c"
    +      - "server_addr=$(cat /opt/cluster/config) && scp -i /opt/cluster/knative.pem -o MACs=hmac-sha2-256 -o  StrictHostKeyChecking=no -oLogLevel=ERROR -o UserKnownHostsFile=/dev/null root@${server_addr}:/opt/ knative-upstream-ci/setup-environment.sh /tmp && . /tmp/setup-environment.sh ${server_addr} && ./test/e2e-tests.sh --run-tests"
    +      volumeMounts:
    +      - name: ppc64le-cluster
    +        mountPath: /opt/cluster
    +        readOnly: true
    +      - name: test-account
    +        mountPath: /etc/test-account
    +        readOnly: true
    +      env:
    +      - name: DISABLE_MD_LINTING
    +        value: "1"
    +      - name: KO_FLAGS
    +        value: "--platform=linux/ppc64le"
    +      - name: DEPLOY_KNATIVE_MONITORING
    +        value: "0"
    +      - name: SYSTEM_NAMESPACE
    +        value: "knative-eventing"
    +      - name: PLATFORM
    +        value: "linux/ppc64le"
    +      - name: KUBECONFIG
    +        value: "/root/.kube/config"
    +      - name: SCALE_CHAOSDUCK_TO_ZERO
    +        value: "1"
    +      - name: JOB
    +        value: "eventing-main"
    +      - name: KO_DOCKER_REPO
    +        valueFrom:
    +          secretKeyRef:
    +            name: ppc64le-cluster
    +            key: ko-docker-repo
    +      - name: GOOGLE_APPLICATION_CREDENTIALS
    +        value: /etc/test-account/service-account.json
    +      - name: E2E_CLUSTER_REGION
    +        value: us-central1
    +    volumes:
    +    - name: ppc64le-cluster
    +      secret:
    +        secretName: ppc64le-cluster
    +        defaultMode: 0600
    +    - name: test-account
    +      secret:
    +        secretName: test-account
     - cron: "0 1 * * *"
       name: ci-knative-eventing-go-coverage
       labels:
    ```

#### Setup secrets on x86 node

The secrets created on upstream server has following structure
- `knative.pem` for ssh access to ppc64le hardware.
- `config` will contain remote ppc64le machine IP.
- `ko-docker-repo` secret environment value for KO_DOCKER_REPO.

For test purpose we need to create them manually. On upstream server they are added via GCP secret manager service. Details can be found in [gcp-secret-manager.md](./gcp-secret-manager.md)
 
```bash
SECRET_DIR=/opt/cluster
mkdir -p ${SECRET_DIR}

cp <id_rsa for access> ${SECRET_DIR}/knative.pem
echo '<remote power machine ip>' > ${SECRET_DIR}/config
export KO_DOCKER_REPO="registry.ppc64le"
```

### Generate prowjobs with mkpj for local testing

More info on mkpj can be found in [RTC Task 140140](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=140140)

- Setup env var

    ```
    export TEST_TOOLS_SRC=$HOME/test-infra-prow
    ```
    
- Clone tools source

    ```
    git clone https://github.com/kubernetes/test-infra.git $TEST_TOOLS_SRC
    cd $TEST_TOOLS_SRC
    ```
    
- Setup environment

    ```
    # Install bazel: https://bazel.build/install/ubuntu

    # Get template knative config required by mkpj tool
    wget https://raw.githubusercontent.com/GoogleCloudPlatform/oss-test-infra/master/prow/knative/config.yaml
    ```
    
- Generate jobs

    ```
    export TEST_TOOLS_SRC=$HOME/test-infra-prow
    export KNATIVE_TEST_SRC=$HOME/test-infra

    CONFIG_PATH=$PWD/config.yaml    #knative config file
    JOB_CONFIG_PATH=$KNATIVE_TEST_SRC/prow/jobs/config.yaml   #ci jobs config file
    JOB_NAME=ci-knative-eventing-ppc64le-e2e-tests  #name of the ci job for which configs should be generated
    JOB_FILE_PATH=/tmp/test-job #file path to store generated configs

    bazel run //prow/cmd/mkpj -- --config-path=$CONFIG_PATH --job-config-path=$JOB_CONFIG_PATH --job=$JOB_NAME > $JOB_FILE_PATH
    ```

### Run prowjobs locally using phaino

More info on mkpj can be found in [RTC Task 140140](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=140140) or in offical phaino [docs](https://github.com/kubernetes/test-infra/tree/master/prow/cmd/phaino).

```
cd $TEST_TOOLS_SRC

# clone the source code of component under test
git clone https://github.com/knative/eventing.git /tmp/eventing

JOB_FILE_PATH=/tmp/test-job #file path of generated prowjob config

bazel run //prow/cmd/phaino -- $JOB_FILE_PATH \
	--skip-volume-mounts=test-account \
	--extra-envs=KO_DOCKER_REPO=${KO_DOCKER_REPO} 

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
git commit -s -m "Add ppc64le nightly job for <component>"
```
