resource "vault_auth_backend" "approle" {
  type = "approle"
}

# Vault team
resource "vault_approle_auth_backend_role" "vault_team" {
  backend        = vault_auth_backend.approle.path
  role_name      = "vault_team"
  token_policies = [vault_policy.vault_team.name, vault_policy.vault_owner.name]
}

resource "vault_approle_auth_backend_role_secret_id" "vault_team" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.vault_team.role_name
}

# Engineering Org
resource "vault_approle_auth_backend_role" "engineering" {
  backend        = vault_auth_backend.approle.path
  role_name      = "engineering"
  token_policies = [vault_policy.engineering.name]
}

resource "vault_approle_auth_backend_role_secret_id" "engineering" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.engineering.role_name
}

# Engineering Team A
resource "vault_approle_auth_backend_role" "engineering_team_a" {
  backend        = vault_auth_backend.approle.path
  role_name      = "engineering_team_a"
  token_policies = [vault_policy.engineering_team_a.name, vault_policy.engineering.name]
}

resource "vault_approle_auth_backend_role_secret_id" "engineering_team_a" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.engineering_team_a.role_name
}

# Engineering Team B
resource "vault_approle_auth_backend_role" "engineering_team_b" {
  backend        = vault_auth_backend.approle.path
  role_name      = "engineering_team_b"
  token_policies = [vault_policy.engineering_team_b.name, vault_policy.engineering.name]
}

resource "vault_approle_auth_backend_role_secret_id" "engineering_team_b" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.engineering_team_b.role_name
}

# Engineering Team C
resource "vault_approle_auth_backend_role" "engineering_team_c" {
  backend        = vault_auth_backend.approle.path
  role_name      = "engineering_team_c"
  token_policies = [vault_policy.engineering_team_c.name, vault_policy.engineering.name]
}

resource "vault_approle_auth_backend_role_secret_id" "engineering_team_c" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.engineering_team_c.role_name
}
