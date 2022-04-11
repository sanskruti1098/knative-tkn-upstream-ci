# Container image buid instructions

This directory contains scripts/instructions to build required images which don't have power support and are used in knative testing. The images are expected to be available in local private registry(running on bastion) or in any public container repository. The image values are used in adjust scripts for image replacements during tests.


|Image|Replacement|Used In|
|:-:|:-:|:-:|
|`projectcontour/contour:v1.19.1`|`registry.ppc64le/contour:v1.19.1`|`serving`|
|`ghcr.io/openzipkin/zipkin:2`|`registry.ppc64le/openzipkin/zipkin:test`|`eventing`|
