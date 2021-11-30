// Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}"
  location = "${var.azure_region}"
  tags     = "${local.tags}"
}

resource "azurerm_redis_cache" "redis-britcache" {
  name                = "${local.redis_cache_name}"
  location            = "${var.azure_region}"
  resource_group_name = "${local.resource_group_name}"
  capacity            = "${var.capacity}"
  family              = "${var.family}"
  sku_name            = "${var.sku_name}"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  depends_on          = ["azurerm_resource_group.rg"]
  tags                = "${local.tags}"
}


// Create Resource Group - UKW
resource "azurerm_resource_group" "rg-ukw" {
  count    = "${local.ukw_resource_count}"
  name     = "${local.resource_group_name_ukw}"
  location = "${var.azure_region_ukw}"
  tags     = "${local.tags_ukw}"
}

resource "azurerm_redis_cache" "redis-britcache-ukw" {
  count               = "${local.ukw_resource_count}"
  name                = "${local.redis_cache_name_ukw}"
  location            = "${var.azure_region_ukw}"
  resource_group_name = "${local.resource_group_name_ukw}"
  capacity            = "${var.capacity_ukw}"
  family              = "${var.family_ukw}"
  sku_name            = "${var.sku_name_ukw}"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  depends_on          = ["azurerm_resource_group.rg-ukw"]
  tags                = "${local.tags_ukw}"
}