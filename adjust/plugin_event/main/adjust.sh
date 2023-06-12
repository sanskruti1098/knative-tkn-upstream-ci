sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
sed -i '/wait_until_pods_running knative-serving || return 1/a kubectl set image deployment/3scale-kourier-gateway kourier-gateway=registry.ppc64le/maistra/envoy:v2.2 -n kourier-system' vendor/knative.dev/hack/library.sh
sed -i 's|gcr.io/knative-samples/helloworld-go|quay.io/openshift-knative/client/helloworld:v1.9|g' pkg/k8s/test/addressresolver_cases.go
