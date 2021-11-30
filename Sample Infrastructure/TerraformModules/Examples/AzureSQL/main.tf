module "AzureSQLModule" {
    source = "../TerraformModules/Modules/AzureSQL"
    
    Location             = var.AzureSQLServer.Test_UKS.Location
    ResourceGroup        = azurerm_resource_group.rg_uks.name
    Tags                 = local.tags

    Licensing            = var.Licensing

    Version              = var.AzureSQLServer.Primary.Server.Version
    TLSVersion           = var.AzureSQLServer.Primary.Server.TLSVersion

    PrimaryRegion        = var.AzureSQLServer.Primary.Location
    SecondaryRegion      = var.AzureSQLServer.Secondary.Location

    AuditStorage         = var.AzureSQLServer.Primary.Auditing.AuditStorageDeploy
    AccountTier          = var.AzureSQLServer.Primary.Auditing.AccountTier
    StorageReplication   = var.AzureSQLServer.Primary.Auditing.StorageReplication

    PrivateEndpoint      = var.AzureSQLServer.Primary.PrivateEndpoint.Deploy
    SubnetName           = var.AzureSQLServer.Primary.PrivateEndpoint.SubnetName
    
    VirtualNetworkName   = var.AzureSQLServer.Primary.PrivateEndpoint.VirtualNetwork.Name
    VirtualNetworkRGName = var.AzureSQLServer.Primary.PrivateEndpoint.VirtualNetwork.ResourceGroupName

    FailoverGroup        = var.AzureSQLServer.Primary.FailoverGroup

    KeyVault             = var.KeyVault
}

# If you needed to create a fresh Resource Group, etc. you can define them here and then use interpolation syntax to reference them in the module inputs above.

