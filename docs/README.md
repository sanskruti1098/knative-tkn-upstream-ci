# Documentation

## Create & Test New Jobs

Refer [job_setup](create_job.md) for the creating/modifying jobs.
Refer [test_job](testing.md) for testing the jobs.

## Setup the cluster-pool node

Refer [cp_setup](cp_setup.md) for the setting up the cluster-pool node for knative-upstream-ci.

## ppc64le-specific images

Refer [ppc64le-images](../images/README.md) to find all the ppc64le-specific images used for knative-upstream-ci.

### TODOs

- [ ] Add retry logic for network failures.
- [ ] Enable slack notifications for failed jobs.
- [ ] Setup monitoring job for Power hardware & k8s cluster & add self healing mechanisms.