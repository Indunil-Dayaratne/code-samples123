locals {
    vm_count    = length(var.VmNames) > 0 ? length(var.VmNames) : var.VmCount
    boot_diag   = var.BootDiagnostics == true || length(var.DiagAccountUri) != 0 ? true : false

    tough_regions   = [
        "East US",
        "East US 2",
        "West US",
        "Central US",
        "North Central US",
        "South Central US",
        "Canada Central",
        "North Europe",
        "West Europe"
    ]
}
