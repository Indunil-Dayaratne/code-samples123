resource "azurerm_resource_group_template_deployment" "sqlmi" {
    name                = "${var.Project}-sqlmi-${var.Environment}-deployment"
    resource_group_name = var.ResourceGroup
    deployment_mode     = "Incremental"
    template_content    = file("${path.module}/sql_managed_instance.json")
    parameters_content  = jsonencode({
        name            = {value = var.name != "false" ? var.name : "${var.Project}-sqlmi-${var.Environment}"}
        location        = {value = var.location}
        sku_name        = {value = var.sku_name}
        license_type    = {value = var.license_type}
        admin_username  = {value = "cloudadmin"}
        admin_password  = {value = var.admin_password}
        subnet_id       = {value = azurerm_subnet.snet.id}
        vcores          = {value = var.vcores}
        storage_size    = {value = var.storage_size}
        collation       = {value = var.collation}
        timezone        = {value = var.timezone}
        public_endpoint = {value = var.PublicEndpoint == true ? true : false}
        tlsversion      = {value = var.tlsversion}
        tags            = {value = var.Tags}
    })
}