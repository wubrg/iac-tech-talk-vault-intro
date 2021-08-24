resource "vault_mount" "engineering" {
  path        = "engineering"
  type        = "kv-v2"
  description = "This is the mount for engineering"
}

resource "vault_mount" "vault_team" {
  path        = "vault_team"
  type        = "kv-v2"
  description = "This is the mount for the vault-team"
}
