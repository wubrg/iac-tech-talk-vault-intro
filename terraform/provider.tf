provider "vault" {
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  # address = "https://vault.example.net:8200"
}

provider "kubernetes" {
  host                     = "https://192.168.64.3:8443"
  config_context_auth_info = "minikube"
  config_context_cluster   = "minikube"
  config_path              = "~/.kube/config"
}
