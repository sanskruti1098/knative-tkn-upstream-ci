# Manage Secrets On Community Prow Server

The knative community uses [kubernetes external secrets](https://github.com/external-secrets/kubernetes-external-secrets) to manage secrets onto their CI server. This allows them to add secrets on to prow server from any client GCP project which can use GCP secret manager service. 

We use GCP project `hidden-bond-335716`. The access details can be found in RTC [Task 146079](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=146079)& [Task 145663](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=145663).

The secret structure used by our setup is as below

- `knative-ssh`: key to access remote ppc64le cluster
- `ci-script`: script to connect and setup remote ppc64le environment

Refer RTC [Task 148096](https://jazz06.rchland.ibm.com:12443/jazz/web/projects/Power%20Ecosystem#action=com.ibm.team.workitem.viewWorkItem&id=148096) for details on how secret is added into the GCP project.

To enable knative prow server to pull secrets from our GCP project, we need to provide permission and add details about the secret in test-infra repo. Refer [knative/test-infra#3224](https://github.com/knative/test-infra/pull/3224) for more details.

# Update a secret in GCP secret manager

Ask Siddhesh Ghadi or Md.afsan Hossain for GCP access credentials.  
Ensure that files have [linux line endings](https://stackoverflow.com/a/34376951) if using windows to push them to GCP.

```bash
gcloud secrets versions add ci-script --data-file="ci-script"

#gcloud secrets versions list ci-script
#gcloud secrets versions access latest --secret="ci-script"
```

