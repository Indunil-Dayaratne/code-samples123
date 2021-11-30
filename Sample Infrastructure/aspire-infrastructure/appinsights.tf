resource "azurerm_application_insights" "current" {
    application_type = "web"
    location = "${azurerm_resource_group.aspire_rg.location}"
    name = "aspire-appinsights-${terraform.workspace}"
    resource_group_name = "${azurerm_resource_group.aspire_rg.name}"
    
    tags = "${local.tags}"
}