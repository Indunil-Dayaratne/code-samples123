resource "azurerm_windows_virtual_machine" "vm" {
  count = var.Linux == true ? 0 : local.vm_count

  name                        = length(var.VmNames) > 0 ? var.VmNames[count.index] : "${var.Project}-vm-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}-${var.Environment}"
  resource_group_name         = var.ResourceGroup
  location                    = var.Location
  size                        = var.Size
  admin_username              = "cloudadmin"
  admin_password              = element(var.AdminPassword, count.index)
  network_interface_ids       = [azurerm_network_interface.nic.*.id[count.index]]
  computer_name               = var.VmNameUpper == true ? upper(length(var.VmNames) > 0 ? var.VmNames[count.index] : "${length(var.Project) >= 11 ? substr(var.Project,0,10) : var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}") : length(var.VmNames) > 0 ? var.VmNames[count.index] : "${length(var.Project) >= 11 ? substr(var.Project,0,10) : var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}"
  license_type                = "Windows_Server"
  timezone                    = "GMT Standard Time"
  enable_automatic_updates    = true
  allow_extension_operations  = true
  tags                        = merge(var.Tags, {hostname = var.VmNameUpper == true ? upper(length(var.VmNames) > 0 ? var.VmNames[count.index] : "${length(var.Project) >= 11 ? substr(var.Project,0,10) : var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}") : length(var.VmNames) > 0 ? var.VmNames[count.index] : "${length(var.Project) >= 11 ? substr(var.Project,0,10) : var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}"})
  availability_set_id         = var.AvailabilitySet == true ? azurerm_availability_set.as[0].id : null
  zone                        = length(var.avzone) > 0 ? var.avzone[count.index] : null
  custom_data                 = var.CustomData == "_false_" ? null : base64encode(var.CustomData)

  os_disk {
      caching               = var.OsDiskCaching
      storage_account_type  = var.OsDiskType
      disk_size_gb          = var.OsDiskSize
  }

  source_image_reference {
      publisher = var.VmImage.Publisher
      offer     = var.VmImage.Offer
      sku       = var.VmImage.Sku
      version   = var.VmImage.Version
  }

  identity {
      type  = "SystemAssigned"
  }

  dynamic "boot_diagnostics" {
    for_each = local.boot_diag == true ? [true] : []

    content {
      storage_account_uri = length(var.DiagAccountUri) == 0 ? azurerm_storage_account.sa-diag[0].primary_blob_endpoint : var.DiagAccountUri
    }
  }

  dynamic "plan" {
    for_each  = var.MarketplacePlan["Name"] == "" ? [] : [true]

    content {
      name      = var.MarketplacePlan["Name"]
      product   = var.MarketplacePlan["Product"]
      publisher = var.MarketplacePlan["Publisher"]
    }
  }

  lifecycle {
    ignore_changes  = [boot_diagnostics]
  }

}

resource "azurerm_linux_virtual_machine" "vm" {
  count = var.Linux == true ? local.vm_count : 0

  name                            = length(var.VmNames) > 0 ? var.VmNames[count.index] : "${var.Project}-vm-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}-${var.Environment}"
  resource_group_name             = var.ResourceGroup
  location                        = var.Location
  size                            = var.Size
  admin_username                  = "cloudadmin"
  admin_password                  = element(var.AdminPassword, count.index)
  network_interface_ids           = [azurerm_network_interface.nic.*.id[count.index]]
  computer_name                   = var.VmNameUpper == true ? upper(length(var.VmNames) > 0 ? var.VmNames[count.index] : "${var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}") : length(var.VmNames) > 0 ? var.VmNames[count.index] : "${var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}"
  allow_extension_operations      = true
  tags                            = merge(var.Tags, {hostname = var.VmNameUpper == true ? upper(length(var.VmNames) > 0 ? var.VmNames[count.index] : "${var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}") : length(var.VmNames) > 0 ? var.VmNames[count.index] : "${var.Project}-${substr(var.Environment,0,1)}-${count.index < 9 ? "0${count.index + 1}" : count.index + 1}"})
  disable_password_authentication = false
  availability_set_id             = var.AvailabilitySet == true ? azurerm_availability_set.as[0].id : null
  zone                            = length(var.avzone) > 0 ? var.avzone[count.index] : null
  custom_data                     = var.CustomData == "_false_" ? null : base64encode(var.CustomData)

  os_disk {
    caching               = var.OsDiskCaching
    storage_account_type  = var.OsDiskType
    disk_size_gb          = var.OsDiskSize
  }

  source_image_reference {
    publisher = var.VmImage["Publisher"]
    offer     = var.VmImage["Offer"]
    sku       = var.VmImage["Sku"]
    version   = var.VmImage["Version"]
  }

  identity {
    type  = "SystemAssigned"
  }

  dynamic "boot_diagnostics" {
    for_each = local.boot_diag == true ? [true] : []

    content {
      storage_account_uri = length(var.DiagAccountUri) == 0 ? azurerm_storage_account.sa-diag[0].primary_blob_endpoint : var.DiagAccountUri
    }
  }

  dynamic "plan" {
    for_each  = var.MarketplacePlan["Name"] == "" ? [] : [true]

    content {
      name      = var.MarketplacePlan["Name"]
      product   = var.MarketplacePlan["Product"]
      publisher = var.MarketplacePlan["Publisher"]
    }
  }

  lifecycle {
    ignore_changes  = [boot_diagnostics]
  }
}
