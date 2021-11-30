variable "Location" {
    type        = string
    description = "Azure Region to deploy into. Defaults to 'UK South'."
    default     = "UK South"
}

variable "ResourceGroup" {
    type        = string
    description = "Name of existing Resource Group to deploy into."
}

variable "Size" {
    type        = string
    description = "Size of the VM to be deployed. Defaults to 'Standard_D2s_v3'."
    default     = "Standard_D2s_v3"
}

variable "AdminPassword" {
    type        = list
    description = "Password for the admin account. Username is 'cloudadmin'."
}

variable "Subnet" {
    type        = string
    description = "ID of the Subnet that the VM NIC will be attached too."
}

variable "Nsg" {
    type        = string
    description = "ID of the NSG that the VM NIC should be associated with."
}

variable "Tags" {
    type        = map
    description = "Map of tags to be applied to the created resources"
}

variable "OsDiskType" {
    type        = string
    description = "Type of storage account for OS Disk. Defaults to 'StandardSSD_LRS'."
    default     = "StandardSSD_LRS"
}

variable "OsDiskSize" {
    type        = string
    description = "Size of OS Disk in GB. Defaults to '127'."
    default     = "127"
}

variable "VmImage" {
    type        = map
    description = "Map of properties for the marketplace image to be used. Must include 'Publisher', 'Offer', 'Sku' and 'Version'. Use the 'Get-AzVmImage*' commands to identify the available values for the region selected. Defaults to 'MicrosoftWindowsServer', 'WindowsServer', '2016-Datacenter' and 'latest' respectively."

    default = {
        Publisher   = "MicrosoftWindowsServer"
        Offer       = "WindowsServer"
        Sku         = "2016-Datacenter"
        Version     = "latest"
    }
}

variable "DomainPassword" {
    type        = string
    description = "Password of the 'WREN\\SVC-djas' account that is used for joining VMs to the domain."
}

variable "Project" {
    type        = string
    description = "Name of the project that the VM is being created for. Used to generate names."
}

variable "Environment" {
    type        = string
    description = "Environment that is being deployed. Used to generate names."
}

variable "VmCount" {
    type        = number
    description = "Number of VMs to be created. Defaults to 1."
    default     = 1
}

variable "VmNames" {
    type        = list
    description = "List of custom VM Names"
    default     = []
}

variable "AvailabilitySet" {
    type        = bool
    description = "Should an availability set be created for the VM(s)?"
    default     = false
}

variable "avzone" {
    type        = list
    description = "Availability zone number"
    default     = []
}

variable "DomainJoin" {
    type        = bool
    description = "Should the VM(s) be joined to the domain? (Windows-only)"
    default     = true
}

variable "Linux" {
    type        = bool
    description = "Is a Linux image being used?"
    default     = false
}

variable "BootDiagnostics" {
    type        = bool
    description = "Should Boot Diagnostics be configured?"
    default     = false
}

variable "DiagStorageID" {
    type        = string
    description = "Single character ID for differentiating Storage Accounts. Gets truncated to single character if more than one is provided."
    default     = ""
}

variable "DiagAccountUri" {
    type        = string
    description = "Blob endpoint URI of the storage account to use for Boot Diagnostics if it already exists. Overides the other Boot Diagnostics settings."
    default     = ""
}

variable "OsDiskCaching" {
    type        = string
    description = "OS Disk Caching Type"
    default     = "ReadWrite"
}

variable "VmNameUpper" {
    type        = bool
    description = "Should the VM Hostnames be in ALL CAPS instead of lower-case? Defaults to false"
    default     = false
}

variable "MarketplacePlan" {
    type        = map
    description = "Map of properties for the marketplace plan to be used. This is only required for marketplace images that have vendor plans (aka costs) associated with them. If needed, the map must include 'Name', 'Product' and 'Publisher'. Use the az cli to get these once you have the source image details - 'az vm image list' to get the specific version number and then 'az vm image show' to get the specific image and plan details. E.g. az vm image show --location uksouth --offer zscaler-private-access --publisher zscaler --skus zpa-con-azure --version 17.20.2 | ConvertFrom-Json | Select-Object -ExpandProperty plan | Format-List"

    default = {
        Name        = ""
        Product     = ""
        Publisher   = ""
    }
}

variable "CustomData" {
    type        = string
    description = "String containing any CustomData to be passed through to the VM at creation time. Defaults to _false_, which can also be used to signify no data is to be passwed through. This data is converted to a Base64 encoded string within the module, so do not provide base64 encoded input."
    default     = "_false_"
}
