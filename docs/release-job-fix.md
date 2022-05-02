# Nightly Release Jobs

Nightly release jobs are automatically added by knative ci using [release-jobs-syncer](https://github.com/knative/test-infra/tree/74007720aeb71bebe917748f1e14c50ede704bff/tools/release-jobs-syncer) tool. Exceptions are added in the tool to not randomly schedule nightly(periodic) jobs for ppc64le. However due to this the new generated jobs take cron value of main branch job which causes conflicts during job runs as we don't have multiple clusters to run jobs. To avoid failures, we manually change the cron values for every new release jobs(added automatically) for ppc64le. 

Refer [knative/test-infra#3302](https://github.com/knative/test-infra/pull/3302) for more details.