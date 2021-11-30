resource "azurerm_storage_account" "sa-diag" {
    count = length(var.DiagAccountUri) == 0 && var.BootDiagnostics == true ? 1 : 0

    name                      = "diagstore${substr(replace(lower(var.Project),"-",""),0,14)}${substr(lower(var.DiagStorageID),0,1)}"
    resource_group_name       = var.ResourceGroup
    location                  = var.Location
    account_tier              = "Standard"
    account_replication_type  = "LRS"
    tags                      = var.Tags
}
