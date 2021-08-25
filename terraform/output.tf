output "vault_team_role_id" {
  value = vault_approle_auth_backend_role.vault_team.role_id
}

output "vault_team_role_secret_id" {
  sensitive = true
  value     = vault_approle_auth_backend_role_secret_id.vault_team.secret_id
}

output "engineering_role_id" {
  value = vault_approle_auth_backend_role.engineering.role_id
}

output "engineering_role_secret_id" {
  sensitive = true
  value     = vault_approle_auth_backend_role_secret_id.engineering.secret_id
}

output "engineering_team_a_role_id" {
  value = vault_approle_auth_backend_role.engineering_team_a.role_id
}

output "engineering_team_a_role_secret_id" {
  sensitive = true
  value     = vault_approle_auth_backend_role_secret_id.engineering_team_a.secret_id
}

output "engineering_team_b_role_id" {
  value = vault_approle_auth_backend_role.engineering_team_b.role_id
}

output "engineering_team_b_role_secret_id" {
  sensitive = true
  value     = vault_approle_auth_backend_role_secret_id.engineering_team_b.secret_id
}
