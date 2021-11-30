variable "Location" {
    type        = string
    description = "Azure Region to deploy into. Defaults to 'UK South'."
    default     = "UK South"
}

variable "ResourceGroup" {
    type        = string
    description = "Name of existing Resource Group to deploy into."
}

variable "Tags" {
    type        = map
    description = "Map of tags to be applied to the created resources"
}

# Azure SQL Server Variables

variable "Version" {
    type        = string
    description = "Version of SQL Server resource to use"
    default     = "12.0"
}

variable "TLSVersion" {
    type        = string
    description = "TLS Version for SQLServer"
    default     = "1.2"
}

variable "PrimaryRegion" {
    type        = string
    description = "Primary Region for Azure SQL Server"
    default     = null
}

variable "SecondaryRegion" {
    type        = string
    description = "Secondary Region for Azure SQL Server"
    default     = null
}

# Azure AD

variable "AzureADAdmin" {
    type        = string
    description = "AzureADAdmin for the SQL Server, will default to SEC-AzureCloud-SQLAdmin Group"
    default     = "SEC-AzureCloud-SQLAdmin"
}

variable "LogRetentionInDays" {
  type          = string
  description   = "Amount of days to retain the logs in storage account"
  default       = "60"
}

# Elastic Pool Variables

variable "SKUName" {
    type        = string
    description = "Name of the SKU for Elastic Pool"
    default     = "StandardPool"
}

variable "SKUTier" {
    type        = string
    description = "Tier of the SKU for Elastic Pool"
    default     = "Standard"
}

variable "SKUCapacity" {
    type        = string
    description = "Capacity of the SKU for Elastic Pool"
    default     = "100"
}

variable "MinCapacity" {
    type        = number
    description = "Minimum per database capacity in Elastic Pool"
    default     = 0
}

variable "MaxCapacity" {
    type        = number
    description = "Maximum per database capacity in Elastic Pool"
    default     = 20
}

variable "MaxSizeGB" {
    type        = number
    description = "Maximum per database capacity in Elastic Pool"
    default     = 750
}

variable "Licensing" {
    type        = string
    description = "Type of licensing options for the elastic pool/server"
    default     = "LicenseIncluded"
}

# Storage Account
variable "AuditStorage" {
    type        = bool
    description = "Deploy storage account for audit"
    default     = false
}

variable "AuditAccount" {
    type        = string
    description = "Account that will be used for audit storage"
    default     = null
}

variable "AuditAccountRGName" {
    type        = string
    description = "Resource Group name of storage account"
    default     = null
}

variable "AccountTier" {
    type        = string
    description = "Type of storage account, Standard or Premium, defaults to Standard"
    default     = "Standard"
}

variable "StorageReplication" {
    type        = string
    description = "Storage account replication type"
    default     = "ZRS"
}

# KeyVault
variable "KeyVault" {
    type        = map
    description = "Reference to KeyVault to store credentials"
}

# PrivateEndpoint
variable "PrivateEndpoint" {
    type        = bool
    description = "Whether private endpoint should be included in deployment"
    default     = null
}

variable "SubnetName" {
    type        = string
    description = "Name of the subnet to put add Private Endpoint"
    default     = null
}

# Virtual Network
variable "VirtualNetworkName" {
    type        = string
    description = "Reference to the Virtual Network for Private Endpoint"
    default     = null
}

variable "VirtualNetworkRGName" {
    type        = string
    description = "Reference to the Virtual Network Resource Group Name"
    default     = "null"
}

# Failover Group
variable "FailoverGroup" {
    type        = bool
    description = "Whether to deploy Failover Group or not"
    default     = false
}

variable "SecondarySQLServer" {
    type        = string
    description = "Secondary Servers to be included in the Failover Group"
    default     = null
}