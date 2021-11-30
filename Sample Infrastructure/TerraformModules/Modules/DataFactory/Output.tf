output "DataFactoryRuntimeKeys" {
    value = contains(var.Runtime["Type"], "Self-Hosted") ? concat(azurerm_data_factory_integration_runtime_self_hosted.runtime.*.auth_key_1, azurerm_data_factory_integration_runtime_self_hosted.runtime.*.auth_key_2) : [""]
}

output "DataFactoryName" {
    value = azurerm_data_factory.df[0].name
}

output "DataFactoryManagedIdentity" {
    value = azurerm_data_factory.df[0].identity[0].principal_id
}
