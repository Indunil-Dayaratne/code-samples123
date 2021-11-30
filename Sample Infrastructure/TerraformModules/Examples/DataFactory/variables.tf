variable "Location" {
    default                 = "UK South"
}
variable "Network" {
    default = {
        Name                = "platform-vnet-uks-dev"
        Group               = "platform-rg-uks-dev"
        Subnet              = "10.0.220.0/27"
    }
}
variable "FactoryCount" {
    default                 = 1
}
variable "Runtime" {
    default = {
        Type                = ["Managed"]
        Count               = 1
        Edition             = "Standard"
        License             = "LicenseIncluded"
        VnetLink            = true
        Node = {
            Size            = "Standard_D2_v3"
            Count           = 2
            ParallelJobs    = 3
        }
    }
}
variable "Tags" {
    default = {
        App                 = "DataFactory-Example"
    }
}
