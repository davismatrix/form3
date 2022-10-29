provider "vault" {
  alias   = "vault_stage"
  address = "http://localhost:8401"
  token   = "mytoken"
}

resource "vault_audit" "audit_stage" {
  provider = vault.vault_stage
  type     = "file"

  options = {
    file_path = "/vault/logs/audit"
  }
}

resource "vault_auth_backend" "userpass_stage" {
  provider = vault.vault_stage
  type     = "userpass"
}

resource "vault_generic_secret" "account_staging" {
  provider = vault.vault_stage
  path     = "secret/staging/account"

  data_json = <<EOT
{
  "db_user":   "account",
  "db_password": "965d3c27-9e20-4d41-91c9-61e6631870e7"
}
EOT
}

resource "vault_policy" "account_staging" {
  provider = vault.vault_stage
  name     = "account-staging"

  policy = <<EOT

path "secret/data/staging/account" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "account_staging" {
  provider             = vault.vault_stage
  depends_on           = [vault_auth_backend.userpass_stage]
  path                 = "auth/userpass/users/account-staging"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["account-staging"],
  "password": "123-account-staging"
}
EOT
}

resource "vault_generic_secret" "gateway_staging" {
  provider = vault.vault_stage
  path     = "secret/staging/gateway"

  data_json = <<EOT
{
  "db_user":   "gateway",
  "db_password": "10350819-4802-47ac-9476-6fa781e35cfd"
}
EOT
}

resource "vault_policy" "gateway_staging" {
  provider = vault.vault_stage
  name     = "gateway-staging"

  policy = <<EOT

path "secret/data/staging/gateway" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "gateway_staging" {
  provider             = vault.vault_stage
  depends_on           = [vault_auth_backend.userpass_stage]
  path                 = "auth/userpass/users/gateway-staging"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["gateway-staging"],
  "password": "123-gateway-staging"
}
EOT
}
resource "vault_generic_secret" "payment_staging" {
  provider = vault.vault_stage
  path     = "secret/staging/payment"

  data_json = <<EOT
{
  "db_user":   "payment",
  "db_password": "a63e8938-6d49-49ea-905d-e03a683059e7"
}
EOT
}

resource "vault_policy" "payment_staging" {
  provider = vault.vault_stage
  name     = "payment-staging"

  policy = <<EOT

path "secret/data/staging/payment" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "payment_staging" {
  provider             = vault.vault_stage
  depends_on           = [vault_auth_backend.userpass_stage]
  path                 = "auth/userpass/users/payment-staging"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["payment-staging"],
  "password": "123-payment-staging"
}
EOT
}

resource "docker_container" "account_staging" {
  image = "${var.docker_image}/platformtest-account"
  name  = "account_staging"

  env = [
    "VAULT_ADDR=http://vault-staging:8200",
    "VAULT_USERNAME=account-staging",
    "VAULT_PASSWORD=123-account-staging",
    "ENVIRONMENT=staging"
  ]

  networks_advanced {
    name = "vagrant_development"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "gateway_staging" {
  image = "${var.docker_image}/platformtest-gateway"
  name  = "gateway_staging"

  env = [
    "VAULT_ADDR=http://vault-staging:8200",
    "VAULT_USERNAME=gateway-staging",
    "VAULT_PASSWORD=123-gateway-staging",
    "ENVIRONMENT=staging"
  ]

  networks_advanced {
    name = "vagrant_staging"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "payment_staging" {
  image = "${var.docker_image}/platformtest-payment"
  name  = "payment_staging"

  env = [
    "VAULT_ADDR=http://vault-staging:8200",
    "VAULT_USERNAME=payment-staging",
    "VAULT_PASSWORD=123-payment-staging",
    "ENVIRONMENT=staging"
  ]

  networks_advanced {
    name = "vagrant_staging"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "frontend_staging" {
  image = "docker.io/nginx:latest"
  name  = "frontend_staging"

  ports {
    internal = 80
    external = 4082
  }

  networks_advanced {
    name = "vagrant_staging"
  }

  lifecycle {
    ignore_changes = all
  }
}
