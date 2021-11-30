locals {
    region                  = substr(replace(var.Location," ",""),0,3)
    runtime = {
        Type                = var.Runtime["Type"]
        Count               = var.Runtime["Count"]
        Edition             = var.Runtime["Edition"]
        License             = var.Runtime["License"]
        Node = {
            Size            = var.Runtime["Node"]["Size"]
            Count           = var.Runtime["Node"]["Count"]
            ParallelJobs    = var.Runtime["Node"]["ParallelJobs"]
        }
        Vnet = {
            Enabled         = var.Runtime["VnetLink"]
            ID              = data.azurerm_virtual_network.vnet.id
            Subnet          = azurerm_subnet.snet.name
        }
    }
}
