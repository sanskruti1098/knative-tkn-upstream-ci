sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
sed -i '/wait_until_pods_running knative-serving || return 1/a kubectl set image deployment/3scale-kourier-gateway kourier-gateway=na.artifactory.swg-devops.com/artifactory/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/maistra/envoy:v2.2 -n kourier-system' vendor/knative.dev/hack/library.sh
sed -i 's|gcr.io/knative-samples/helloworld-go|quay.io/openshift-knative/client/helloworld:v1.9|g' pkg/k8s/test/addressresolver_cases.go
sed -i '/^success.*/i .\/destroy.sh' test/e2e-tests.sh
sed -i '/.*dump_cluster_state().*/a\  .\/destroy.sh' vendor/knative.dev/hack/infra-library.sh
kubectl get cm vcm-script -n default -o jsonpath='{.data.script}' > destroy.sh && chmod +x destroy.sh