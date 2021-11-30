resource "azurerm_data_factory_integration_runtime_azure_ssis" "runtime" {
    name                                = contains(keys(var.Runtime), "Name") && contains(var.Runtime["Type"], "SSIS") ? var.Runtime["Name"][index(var.Runtime["Type"], "SSIS")] : "${var.Project}-ssis-ir-${count.index <= 9 ? "0" : ""}${count.index + 1}-${local.region}"
    data_factory_name                   = azurerm_data_factory.df[count.index].name
    resource_group_name                 = var.ResourceGroup
    location                            = var.Location

    node_size                           = var.Runtime["Node"]["Size"]
    number_of_nodes                     = var.Runtime["Node"]["Count"]
    max_parallel_executions_per_node    = var.Runtime["Node"]["ParallelJobs"]
    edition                             = var.Runtime["Edition"]
    license_type                        = var.Runtime["License"]

    dynamic "vnet_integration" {
        for_each = var.Runtime["Vnet"]["Enabled"] == true ? [true] : []
        content {
            vnet_id                     = var.Runtime["Vnet"]["ID"]
            subnet_name                 = var.Runtime["Vnet"]["Subnet"]
        }
    }

    count                               = contains(var.Runtime["Type"], "SSIS") ? var.Runtime["Count"][index(var.Runtime["Type"], "SSIS")] : 0
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "runtime" {
    name                                = contains(keys(var.Runtime), "Name") && contains(var.Runtime["Type"], "Self-Hosted") ? var.Runtime["Name"][index(var.Runtime["Type"], "Self-Hosted")] : "${var.Project}-sh-ir-${count.index <= 9 ? "0" : ""}${count.index + 1}-${local.region}"
    data_factory_name                   = azurerm_data_factory.df[count.index].name
    resource_group_name                 = var.ResourceGroup
    count                               = contains(var.Runtime["Type"], "Self-Hosted") ? var.Runtime["Count"][index(var.Runtime["Type"], "Self-Hosted")] : 0
}

resource "azurerm_data_factory_integration_runtime_azure" "runtime" {
    name                                = contains(keys(var.Runtime), "Name") && contains(var.Runtime["Type"], "Managed") ? var.Runtime["Name"][index(var.Runtime["Type"], "Managed")] : "${var.Project}-man-ir-${count.index <= 9 ? "0" : ""}${count.index + 1}-${local.region}"
    data_factory_name                   = azurerm_data_factory.df[count.index].name
    resource_group_name                 = var.ResourceGroup
    location                            = var.Location

    compute_type                        = var.Runtime["ComputeType"]
    core_count                          = var.Runtime["CoreCount"]
    time_to_live_min                    = var.Runtime["TTLMin"]

    count                               = contains(var.Runtime["Type"], "Managed") ? var.Runtime["Count"][index(var.Runtime["Type"], "Managed")] : 0
}
