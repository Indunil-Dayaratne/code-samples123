module "appservice-linux" {

  source = "./tf-module-app-service"

  resource_prefix               = "${lookup(local.tags,"app")}"
  azure_short_region            = "${data.terraform_remote_state.platform.platform_region_prefix}"
  environment                   = "${terraform.workspace}"

  resource_group_name           = "${azurerm_resource_group.app-rg.name}"
  resource_group_location       = "${azurerm_resource_group.app-rg.location}"

  app_service_plan_kind         = "${var.app_service_plan_kind}"

  app_service_plan_sku_tier     = "${var.app_service_plan_sku_tier}"
  app_service_plan_sku_size     = "${var.app_service_plan_sku_size}"
  app_service_plan_sku_capacity = "${var.app_service_plan_sku_capacity}"

  app_service_plan_reserved     = "${var.app_service_plan_reserved}"

  tags                          = "${local.tags}" 
}
