resource "azurerm_data_factory" "df" {
    name                = "${var.Project}-adf-${count.index >= 9 ? "0" : ""}${count.index + 1}-${local.region}-${var.Environment}"
    resource_group_name = var.ResourceGroup
    location            = var.Location
    tags                = var.Tags
    count               = var.FactoryCount
    identity {
        type            = "SystemAssigned"
    }

    dynamic "vsts_configuration" {
        for_each = var.DevOpsIntegrated == true ? [true] : []

        content {
            tenant_id       = var.DevOpsConfig.TenantId
            account_name    = var.DevOpsConfig.Account
            project_name    = var.DevOpsConfig.Project
            repository_name = var.DevOpsConfig.Repository
            branch_name     = var.DevOpsConfig.Branch
            root_folder     = var.DevOpsConfig.Folder
        }
    }

    lifecycle {
        ignore_changes = [global_parameter]
    }

}


