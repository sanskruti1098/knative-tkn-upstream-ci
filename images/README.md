# Container image for ppc64le

This directory contains scripts/instructions to build required images which don't have power support and are used in knative testing. The images are expected to be available in JFrog registry(na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative). The image values are used in adjust scripts for image replacements during tests.


|Image|Replacement|Used In|
|:-:|:-:|:-:|
|`projectcontour/contour:v1.25.0`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/contour:v1.25.0`|`serving`|
|`ghcr.io/openzipkin/zipkin:2`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/openzipkin/zipkin:test`|`eventing`,`eventing-kafka-broker`|
|`docker.io/envoyproxy/envoy:v1.28.0`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/maistra/envoy:v2.4`|`eventing`,`plugin-event`|
|`ghcr.io/pierdipi/sacura/sacura-7befbbbc92911c6727467cfbf23af88f`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/bootstrap/sacura:latest`|`eventing-kafka-broker`|
|`docker.io/edenhill/kafkacat:1.6.0`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/kafkacat:v1.6.0`|`eventing-kafka-broker`|
|`ghcr.io/kedacore/keda-admission-webhooks:2.10.1`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/keda-webhook:v2.11.2`|`eventing-kafka-broker`|
|`ghcr.io/kedacore/keda-metrics-apiserver:2.10.1`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/keda-adapter:v2.11.2`|`eventing-kafka-broker`|
|`ghcr.io/kedacore/keda:2.10.1`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/keda-main:v2.11.2`|`eventing-kafka-broker`|
|`ghcr.io/kedacore/keda:2.10.1`|`docker-na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/keda-main:v2.11.2`|`eventing-kafka-broker`|