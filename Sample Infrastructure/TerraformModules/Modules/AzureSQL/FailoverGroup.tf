resource "azurerm_mssql_server" "azsqlserver-secondary" {
    count                        = var.FailoverGroup == true ? 1 : 0

    name                         = replace(local.secondarybasename, "##", "sqlserv")
    resource_group_name          = var.ResourceGroup
    location                     = var.SecondaryRegion
    version                      = var.Version
    administrator_login          = "cloudadmin"
    administrator_login_password = random_password.sqlserver-secondary[0].result
    minimum_tls_version          = var.TLSVersion

    tags                         = var.Tags

    azuread_administrator {
        login_username             = var.AzureADAdmin
        object_id                  = data.azuread_group.sqladmin.id
    }
}

resource "azurerm_mssql_elasticpool" "epool-secondary" {
    count               = var.FailoverGroup == true ? 1 : 0

    name                = replace(local.secondarybasename, "##", "epool")
    resource_group_name = var.ResourceGroup
    location            = var.SecondaryRegion
    server_name         = azurerm_mssql_server.azsqlserver-secondary[0].name
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

resource "azurerm_sql_failover_group" "fog" {
    count               = var.FailoverGroup == true ? 1 : 0

    name                = replace(local.basename, "##-${local.region}", "fog")
    resource_group_name = var.ResourceGroup
    server_name         = azurerm_mssql_server.azsqlserver-primary.name
    databases           = []
    partner_servers {
        id = azurerm_mssql_server.azsqlserver-secondary[0].id
    }

    read_write_endpoint_failover_policy {
        mode          = "Automatic"
        grace_minutes = 60
    }


    lifecycle {
        ignore_changes = [server_name, partner_servers]
    }
}