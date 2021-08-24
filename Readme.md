
## Setup

### Mac

- Docker for Desktop

- ```
brew install kubernetes-cli
brew install helm
brew install minikube
brew install tfenv
brew tap hashicorp/tap
brew install hashicorp/tap/vault
brew upgrade hashicorp/tap/vault

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

```

## Components

### Consul

https://www.consul.io/docs/k8s/helm

## Startup

```
minikube start
minikube status

helm install consul hashicorp/consul --values helm-values/consul.yml
kubectl get pods

helm install vault hashicorp/vault --values helm-values/vault.yml

kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY

kubectl port-forward vault-0 8200:8200 &

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root_token

cd terraform
tf init
tf plan
```
