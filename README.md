# pulumi-continuous

Docker image with kubectl, helm and pulumi for simple continuous deployment/delivery.

```
# create a service account with cluster-admin role
kubectl create serviceaccount deployer
kubectl create clusterrolebinding deployer-cluster-rule --clusterrole=cluster-admin --serviceaccount=default:deployer
```

```
export PULUMI_ACCESS_TOKEN=...
export PULUMI_STACK=...
export K8S_SERVER=https://...
export K8S_BEARER_TOKEN=$(kubectl get secret $(kubectl get serviceaccount deployer -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 -d)
export K8S_CERTIFICATE_AUTHORITY=$(kubectl get secret $(kubectl get serviceaccount deployer -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.ca\.crt}")

docker run --rm \
    -e PULUMI_ACCESS_TOKEN=${PULUMI_ACCESS_TOKEN} \
    -e PULUMI_STACK=${PULUMI_STACK} \
    -e K8S_SERVER=${K8S_SERVER} \
    -e K8S_CERTIFICATE_AUTHORITY=${K8S_CERTIFICATE_AUTHORITY} \
    -e K8S_BEARER_TOKEN=${K8S_BEARER_TOKEN} \
    -v $PWD:/deployment \
    choffmeister/pulumi-continuous:latest \
    "yarn install --pure-lockfile && pulumi up --yes"
```
