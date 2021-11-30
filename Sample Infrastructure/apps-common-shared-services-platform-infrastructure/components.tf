// Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}"
  location = "${var.azure_region}"
  tags     = "${local.tags}"
}

resource "azurerm_frontdoor" "front-door" {
  count                                        = "${var.azure_front_door_setup == "true"? 1 : 0}"
  name                                         = "${local.front_door_name}"
  location                                     = "global"
  resource_group_name                          = "${local.resource_group_name}"
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "default"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["${local.front_door_name}"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "default"
    }
  }

  backend_pool_load_balancing {
    name = "default"
  }

  backend_pool_health_probe {
    name = "default"
  }

  backend_pool {
    name = "default"
    backend {
      host_header = "default.azurewebsites.net"
      address     = "default.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority = 1
      weight  = 100
    }
    load_balancing_name = "default"
    health_probe_name   = "default"
  }

  frontend_endpoint {
    name                              = "${local.front_door_name}"
    host_name                         = "${local.front_door_name}.azurefd.net"
    custom_https_provisioning_enabled = false
  }

  lifecycle {
    ignore_changes = ["backend_pool","backend_pool","backend_pool_load_balancing","backend_pool_health_probe","routing_rule"]
  }
}


resource "azurerm_key_vault" "keyvault" {
  name                        = "${local.key_vault_name}"
  location                    = "${var.azure_region}"
  resource_group_name         = "${local.resource_group_name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"
  depends_on                  = ["azurerm_resource_group.rg"]

  sku {
    name = "standard"
  }

   access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.spn_object_id}"
    # application_id = "${var.spn_app_id}"

    secret_permissions = [
      "get",
      "list",
      "set"
    ]
  }


  lifecycle {
    ignore_changes = [
      "access_policy"
    ]
  }

  tags = "${local.tags}"
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                        = "${local.cosmos_db_name}"
  location                    = "${var.azure_region}"
  resource_group_name         = "${local.resource_group_name}"
  offer_type                  = "Standard"
  kind                        = "GlobalDocumentDB"
  depends_on                  = ["azurerm_resource_group.rg"]
  
  enable_automatic_failover   = true

  consistency_policy {
    consistency_level         = "BoundedStaleness"
    max_interval_in_seconds   = 360
    max_staleness_prefix      = 120000
  }


  geo_location {
    location                  = "${var.azure_failover_region}"
    failover_priority         = 1
  }

  geo_location {
    prefix                    = "${local.cosmos_db_prefix}"
    location                  = "${var.azure_region}"
    failover_priority         = 0
  }

  tags = "${local.tags}"
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_database" {
  name                = "shared"
  resource_group_name = "${local.resource_group_name}"
  account_name        = "${azurerm_cosmosdb_account.cosmosdb.name}"
}

resource "azurerm_key_vault_secret" "cosmos-account-primary-key" {
  name                        = "cosmos-account-primary-key"
  value                       = "${azurerm_cosmosdb_account.cosmosdb.primary_master_key}"
  key_vault_id                = "${azurerm_key_vault.keyvault.id}"
  depends_on                  = ["azurerm_resource_group.rg", "azurerm_key_vault.keyvault", "azurerm_cosmosdb_account.cosmosdb"]
}

resource "azurerm_key_vault_secret" "cosmos-account-secondary-key" {
  name                        = "cosmos-account-secondary-key"
  value                       = "${azurerm_cosmosdb_account.cosmosdb.secondary_master_key}"
  key_vault_id                = "${azurerm_key_vault.keyvault.id}"
  depends_on                  = ["azurerm_resource_group.rg", "azurerm_key_vault.keyvault", "azurerm_cosmosdb_account.cosmosdb"]
}

resource "azurerm_key_vault_secret" "cosmos-account-primary-readonly-key" {
  name                        = "cosmos-account-primary-readonly-key"
  value                       = "${azurerm_cosmosdb_account.cosmosdb.primary_readonly_master_key}"
  key_vault_id                = "${azurerm_key_vault.keyvault.id}"
  depends_on                  = ["azurerm_resource_group.rg", "azurerm_key_vault.keyvault", "azurerm_cosmosdb_account.cosmosdb"]
}

resource "azurerm_key_vault_secret" "cosmos-account-secondary-readonly-key" {
  name                        = "cosmos-account-secondary-readonly-key"
  value                       = "${azurerm_cosmosdb_account.cosmosdb.secondary_readonly_master_key}"
  key_vault_id                = "${azurerm_key_vault.keyvault.id}"
  depends_on                  = ["azurerm_resource_group.rg", "azurerm_key_vault.keyvault", "azurerm_cosmosdb_account.cosmosdb"]
}