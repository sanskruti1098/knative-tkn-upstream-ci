# Knative Upstream CI
This repo hosts automation, configurations, documentation &amp; scripts to enable/support [Knative](https://knative.dev) upstream CI on ppc64le.

### Introduction
Knative is an open-source platform for serverless workloads on Kubernetes, streamlining the deployment and management of serverless applications by handling infrastructure details, letting developers concentrate on code, and include features like auto-scaling and event-driven capabilities, which uses [Prow](https://docs.prow.k8s.io/) a Kubernetes-native CI/CD system to automate and manage their CI workflows.

## PPC64le Knative jobs
We've enabled knative CI for the following knative components on ppc64le : 
`client`,`eventing`,`eventing-kafka-broker`,`operator`,`plugin-event`,`serving`.

Here's the [link](https://prow.knative.dev/?job=ppc64le-*) to the ppc64le Knative prow jobs. 

This [repo](https://github.com/knative/infra) hosts the configs for prow . We raise a PR here to add/modify/remove any Knative job.

## Documentation
Please read the project [documentation](./docs/README.md) to familiarize with the project setup, involved processes, environments and components.