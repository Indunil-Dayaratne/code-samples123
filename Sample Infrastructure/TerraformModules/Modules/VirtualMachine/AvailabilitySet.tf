resource "azurerm_availability_set" "as" {
    name                            = "${var.Project}-as-${var.Environment}"
    resource_group_name             = var.ResourceGroup
    location                        = var.Location
    platform_fault_domain_count     = contains(local.tough_regions, var.Location) ? 3 : 2
    platform_update_domain_count    = 20
    tags                            = var.Tags

    count                           = var.AvailabilitySet == true ? 1 : 0
}
