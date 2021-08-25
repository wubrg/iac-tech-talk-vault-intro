
# IAC Guild Vault Intro

This demo is loosely based on
- https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
- https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube?in=vault/kubernetes#configure-kubernetes-authentication

## Setup

### K8s Minikube with Helm and Terraform

```
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
export VAULT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")

echo $VAULT_TOKEN | vault login -

cd terraform
tf init
tf plan

export ENG_ROLE_ID=$(tf output engineering_role_id | tr -d '"')
export ENG_ROLE_SECRET_ID=$(tf output engineering_role_secret_id | tr -d '"')
export TEAM_A_ROLE_ID=$(tf output engineering_team_a_role_id | tr -d '"')
export TEAM_A_ROLE_SECRET_ID=$(tf output engineering_team_a_role_secret_id | tr -d '"')
export TEAM_B_ROLE_ID=$(tf output engineering_team_b_role_id | tr -d '"')
export TEAM_B_ROLE_SECRET_ID=$(tf output engineering_team_b_role_secret_id | tr -d '"')
export VAULT_TEAM_ROLE_ID=$(tf output vault_team_role_id | tr -d '"')
export VAULT_TEAM_ROLE_SECRET_ID=$(tf output vault_team_role_secret_id | tr -d '"')
```

## Make some secrets

Create some secrets under the mounts (with root token)

```
vault login
vault kv patch engineering/favorites animal=monkeys
vault kv patch engineering/favorites food=pizza
vault kv patch engineering/team_a/favorites animal=lions
vault kv patch engineering/team_a/favorites food=steak
vault kv patch engineering/team_b/favorites animal=dogs
vault kv patch engineering/team_b/favorites food=burgers
vault kv patch engineering/team_c/favorites animal=sneks
vault kv patch engineering/team_c/favorites food=chocolate
vault kv patch vault_team/favorites animal=phish
vault kv patch vault_team/favorites food=pancakes
```

## Access secret (simulated via approle auth method)

### Engineering Role
```
export VAULT_TOKEN=$(vault write auth/approle/login role_id=$ENG_ROLE_ID secret_id=$ENG_ROLE_SECRET_ID -format=json | jq -r '.auth.client_token')

echo $VAULT_TOKEN | vault login -

vault kv get engineering/favorites
vault kv list engineering/team_a
vault kv get vault_team/favorites
```

This first get fails bc only list and create on engineering*, no read

The second command succeeds bc we do have list permission

The third command fails but does not confirm whether or not the path exists, only that the policy does not grant access to the requested path


### Engineering Team A Role
```
export VAULT_TOKEN=$(vault write auth/approle/login role_id=$TEAM_A_ROLE_ID secret_id=$TEAM_A_ROLE_SECRET_ID -format=json | jq -r '.auth.client_token')

echo $VAULT_TOKEN | vault login -

vault kv get engineering/team_a/favorites
vault kv list engineering/team_b
vault kv get vault_team/favorites
```

The first succeeds because we have read permission for team_a/*

The second succeeds because we have the basic engineering policy attached to our role

The third command fails but does not confirm whether or not the path exists, only that the policy does not grant access to the requested path

### Vault Team Role
```
export VAULT_TOKEN=$(vault write auth/approle/login role_id=$VAULT_TEAM_ROLE_ID secret_id=$VAULT_TEAM_ROLE_SECRET_ID -format=json | jq -r '.auth.client_token')

echo $VAULT_TOKEN | vault login -

vault kv get engineering/favorites
vault kv get engineering/team_a/favorites
vault kv list engineering/team_b
vault kv get vault_team/favorites
```

All of the above succeed because we're using the vault team's vault owner role, which is our root replacement policy role. 
