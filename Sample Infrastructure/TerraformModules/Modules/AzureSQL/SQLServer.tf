data "azuread_group" "sqladmin" {
    display_name        = var.AzureADAdmin
    security_enabled    = true
}

resource "azurerm_mssql_server" "azsqlserver-primary" {
    name                         = replace(local.basename, "##", "sqlserv")
    resource_group_name          = var.ResourceGroup
    location                     = var.PrimaryRegion
    version                      = var.Version
    administrator_login          = "cloudadmin"
    administrator_login_password = random_password.sqlserver-primary.result
    minimum_tls_version          = var.TLSVersion

    tags                         = var.Tags

    azuread_administrator {
        login_username  = var.AzureADAdmin
        object_id       = data.azuread_group.sqladmin.id
    }
}

resource "azurerm_mssql_elasticpool" "epool-primary" {
    name                = replace(local.basename, "##", "epool")
    resource_group_name = var.ResourceGroup
    location            = var.Location
    server_name         = azurerm_mssql_server.azsqlserver-primary.name
    license_type        = var.Licensing
    max_size_gb         = var.MaxSizeGB

    tags                = var.Tags

    sku {
        name     = var.SKUName
        tier     = var.SKUTier
        capacity = var.SKUCapacity
    }

    per_database_settings {
        min_capacity = var.MinCapacity
        max_capacity = var.MaxCapacity
    }
}