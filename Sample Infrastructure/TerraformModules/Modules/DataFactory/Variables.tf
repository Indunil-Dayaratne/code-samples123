variable "Project" {
    type        = string
    description = "Name of the project that the Data Factory is being created for. Used to generate names."
}
variable "ResourceGroup" {
    type        = string
    description = "Name of existing Resource Group to deploy into."
}
variable "Location" {
    type        = string
    description = "Azure Region to deploy into. Defaults to 'UK South'."
    default     = "UK South"
}
variable "Tags" {
    type        = map
    description = "Map of tags to be applied to the created resources."
}
variable "FactoryCount" {
    type        = number
    description = "Number of Data Factories to be created. Defaults to 1."
    default     = 1
}
variable "Runtime" {
    type        = any
    description = "Map of properties for the integration runtime(s) to be created. Must include 'Type' and 'Count', 'Count' is a list with the values corelating to the Type. 'Type' must be a List, and contain 'SSIS' for Azure-managed runtimes or 'Self-Hosted' for self-hosted runtimes or 'Managed' for an Azure integration runtime. Can also be a combination of the three e.g. ['Self-Hosted', 'Managed']. SSIS runtimes will need extra values for 'Node', 'Edition' and 'License', as well as 'Vnet' if being integrated. 'Managed' has optional 'ComputeType', 'CoreCount', and 'TTLMin'. Default is to create a single self-hosted runtime, refer to the examples if you wish to create a managed runtime."
    default     = {
        Type    = ["Self-Hosted"]
        Count   = [1]
    }
}
variable "Environment" {
    type        = string
    description = "Environment that is being deployed. Used to generate names."
}

variable "DevOpsIntegrated" {
    type        = bool
    default     = false
    description = "Is this DataFactory to be integrated with an Azure DevOps repository? Defaults to false"
}

variable "DevOpsConfig" {
    type        = any
    description = "Configuration details used to integrate with an Azure DevOps repository. Requires 'DevOpsIntegrated' to be set to true in order to have any effect"
    default = {
        TenantId    = ""
        Account     = ""
        Project     = ""
        Repository  = ""
        Branch      = ""
        Folder      = ""
    }
}
