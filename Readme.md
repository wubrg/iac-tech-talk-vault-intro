
# IAC Guild Vault Intro

This demo aims to show some of the high-level features of Vault as well as show off the vault terraform provider to manage those features in code.

This demo is loosely based on
- https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
- https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube?in=vault/kubernetes#configure-kubernetes-authentication

## Vault Concepts

### Sealed / Unsealed

Vault is initialized in the _sealed_ state. Most Vault data is encrypted using the encryption key in the keyring; the keyring is encrypted by the master key; and the master key is encrypted by the unseal key.

### Paths

Vault's architecture is similar to a filesystem. Every action in Vault has a corresponding path and capability. Policies define access to these paths and capabilities, which controls a token's access to credentials in Vault.

### Authentication

Vault supports multiple authentication methods, which must be enabled / configured before they can be used. There are user-based auth methods and there are machine-based auth methods. Once authenticated Vault will return a token to use when interacting with Vault. The token will be mapped to a role/policy and have a lease (expiration).

### Policies

Policies provide a declarative way to grant or forbid access to certain paths and operations in Vault. Policies are deny by default.

### Secrets Engine



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
export TEAM_C_ROLE_ID=$(tf output engineering_team_c_role_id | tr -d '"')
export TEAM_C_ROLE_SECRET_ID=$(tf output engineering_team_c_role_secret_id | tr -d '"')
export VAULT_TEAM_ROLE_ID=$(tf output vault_team_role_id | tr -d '"')
export VAULT_TEAM_ROLE_SECRET_ID=$(tf output vault_team_role_secret_id | tr -d '"')
```

## Make some secrets

Seed some play data

```
export VAULT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")
echo $VAULT_TOKEN | vault login -

vault kv put engineering/favorites animal=monkeys
vault kv put engineering/favorites food=pizza
vault kv put engineering/team_a/favorites animal=lions
vault kv put engineering/team_a/favorites food=steak
vault kv put engineering/team_b/favorites animal=dogs
vault kv put engineering/team_b/favorites food=burgers
vault kv put engineering/team_c/favorites animal=sneks
vault kv put engineering/team_c/favorites food=chocolate
vault kv put vault_team/favorites animal=phish
vault kv put vault_team/favorites food=pancakes
vault kv put vault_team/favorites language=go
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

The first and second succeed because we have read permission for engineering/+/team_a

The third succeeds because we have the basic engineering policy attached to our role, which grants list access to all secrets under engineering

The fourth command fails but does not confirm whether or not the path exists, only that the policy does not grant access to the requested path. Without a policy for the vault_team mount attached to our token, vault does not confirm the requested item even exists.

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
