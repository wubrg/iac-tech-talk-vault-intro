output "vault_team_role_id" {
  value = vault_approle_auth_backend_role.vault_team.role_id
}

output "engineering_role_id" {
  value = vault_approle_auth_backend_role.engineering.role_id
}

output "engineering_team_a_role_id" {
  value = vault_approle_auth_backend_role.engineering_team_a.role_id
}

output "engineering_team_b_role_id" {
  value = vault_approle_auth_backend_role.engineering_team_b.role_id
}
