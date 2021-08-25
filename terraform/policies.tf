resource "vault_policy" "public" {
  name   = "vault_everyone_policy"
  policy = data.vault_policy_document.public_secrets.hcl
}

data "vault_policy_document" "public_secrets" {
  rule {
    path         = "engineering/*"
    capabilities = ["list"]
    description  = "allow List on secrets under engineering/ path"
  }
}

resource "vault_policy" "vault_owner" {
  name   = "vault_owner_policy"
  policy = data.vault_policy_document.vault_owner_secrets.hcl
}

data "vault_policy_document" "vault_owner_secrets" {
  rule {
    path         = "engineering*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets under engineering/ path for vault owners"
  }
}

resource "vault_policy" "engineering" {
  name   = "engineering_policy"
  policy = data.vault_policy_document.engineering_secrets.hcl
}

data "vault_policy_document" "engineering_secrets" {
  rule {
    path         = "engineering*"
    capabilities = ["create", "list"]
    description  = "allow create and list on secrets under engineering/"
  }
}

resource "vault_policy" "engineering_team_a" {
  name   = "engineering_team_a_policy"
  policy = data.vault_policy_document.engineering_team_a_secrets.hcl
}

data "vault_policy_document" "engineering_team_a_secrets" {
  rule {
    path         = "engineering/team_a*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets under engineering/team_a"
  }
}

resource "vault_policy" "engineering_team_b" {
  name   = "engineering_team_b_policy"
  policy = data.vault_policy_document.engineering_team_b_secrets.hcl
}

data "vault_policy_document" "engineering_team_b_secrets" {
  rule {
    path         = "engineering/team_b*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets under engineering/team_b"
  }
}

resource "vault_policy" "engineering_team_c" {
  name   = "engineering_team_c_policy"
  policy = data.vault_policy_document.engineering_team_c_secrets.hcl
}

data "vault_policy_document" "engineering_team_c_secrets" {
  rule {
    path         = "engineering/team_c*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets under engineering/team_c"
  }
}

resource "vault_policy" "vault_team" {
  name   = "vault_team_policy"
  policy = data.vault_policy_document.vault_team_secrets.hcl
}

data "vault_policy_document" "vault_team_secrets" {
  rule {
    path         = "vault_team*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets under vault_team"
  }
}
