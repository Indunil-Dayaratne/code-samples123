// Refer to Resource Group
data "azurerm_resource_group" "platform-rg" {
  name                              = local.platform_resource_group_name 
}

data "azurerm_resource_group" "rg" {
  name                              = local.resource_group_name
}

data "azurerm_resource_group" "api-primary-rg" {
  count                             = var.apiCount
  name                              = "${var.api_resource_groups[count.index]}-rg-${var.azure_short_region}-${terraform.workspace}"
}

data "azurerm_resource_group" "api-dr-rg" {
  count                             = var.apiCount
  name                              = "${var.api_resource_groups[count.index]}-rg-${var.azure_short_region_dr}-${terraform.workspace}"
}

data "azurerm_function_app" "api-primary-app" {
  count                             = var.apiCount
  name                              = "${var.apis[count.index]}-func-${terraform.workspace}"
  resource_group_name               = data.azurerm_resource_group.api-primary-rg[count.index].name
}

data "azurerm_function_app" "api-dr-app" {
  count                             = var.apiCount
  name                              = "${var.apis[count.index]}-func-${var.azure_short_region_dr}-${terraform.workspace}"
  resource_group_name               = data.azurerm_resource_group.api-dr-rg[count.index].name
}

data "azurerm_virtual_network" "platform-vnet" {
  name                              = "platform-vnet01-${var.azure_short_region}-${var.environment_postfix}"
  resource_group_name               = data.azurerm_resource_group.platform-rg.name
}

resource "azurerm_subnet" "gateway-subnet" {
  name                              = "agw-sn01-${var.azure_short_region}-${var.environment_postfix}"
  resource_group_name               = data.azurerm_resource_group.platform-rg.name
  virtual_network_name              = data.azurerm_virtual_network.platform-vnet.name
  address_prefixes                  = [local.subnet_address_prefix]
}

resource "azurerm_public_ip" "pip" {
  name                              = "shared-agw-pip-${terraform.workspace}"
  location                          = var.azure_region
  resource_group_name               = data.azurerm_resource_group.rg.name
  allocation_method                 = "Dynamic"
  domain_name_label                 = "brit-shared-apis-${terraform.workspace}"
}

resource "azurerm_application_gateway" "app-gateway" {
  name                              = local.app_gateway_name
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = var.azure_region

  sku {
    name     = "Standard_Medium"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "subnet"
    subnet_id = "${data.azurerm_virtual_network.platform-vnet.id}/subnets/${azurerm_subnet.gateway-subnet.name}"
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
      name        = "app-service-backend-pool-${terraform.workspace}"
  }

  dynamic "backend_address_pool" {
    for_each = [for api in var.apis: {
        name = "${api}-pool-${terraform.workspace}"
        primary_app_service = "${api}-func-${terraform.workspace}.azurewebsites.net"
        dr_app_service = "${api}-func-${var.azure_short_region_dr}-${terraform.workspace}.azurewebsites.net"
    }]
    
    content {
        name        = backend_address_pool.value.name
        fqdns       = [backend_address_pool.value.primary_app_service, backend_address_pool.value.dr_app_service]
    }
    
  }

  http_listener {
    name                           = "api-http-listener"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "https"
    protocol                       = "Https"
  }

  dynamic "probe" {
    for_each = [for api in var.apis: {
        name = "${api}-probe-${terraform.workspace}"        
    }]

    content {
        name                                      = probe.value.name
        protocol                                  = "https"
        path                                      = "/api/v2/HealthCheck"
        pick_host_name_from_backend_http_settings = true
        interval                                  = "300"
        timeout                                   = "30"
        unhealthy_threshold                       = "3"
        match {
          status_code                             = ["200","401","403"]
        }                                
    }
  }

  dynamic "backend_http_settings" {
    for_each = [for api in var.apis: {
        name = "${api}-http-setting-${terraform.workspace}"
        probe_name = "${api}-probe-${terraform.workspace}"        
    }]

    content {
      name                                        = backend_http_settings.value.name
      cookie_based_affinity                       = "Disabled"
      port                                        = 443
      protocol                                    = "Https"
      request_timeout                             = 5
      path                                        = "/api/v2"
      pick_host_name_from_backend_address         = true
      probe_name                                  = backend_http_settings.value.probe_name
    }
  }

  url_path_map {
    name                                          = "agw-url-path-map-${terraform.workspace}"

    dynamic "path_rule" {
        for_each = [for api in var.apis: {
          path = format("/%s*", replace(replace(api, "-api", ""), "-", "/"))
          name = format("%s-path-rule-${terraform.workspace}", api)
          http_settings_name = format("%s-http-setting-${terraform.workspace}", api)
          backend_pool_name = format("%s-pool-${terraform.workspace}", api)               
      }]

      content {
        name                                      = path_rule.value.name
        paths                                     = [path_rule.value.path]
        backend_http_settings_name                = path_rule.value.http_settings_name
        backend_address_pool_name                 = path_rule.value.backend_pool_name
      }
    }
  }

  request_routing_rule {
    name                                          = "http"
    rule_type                                     = "PathBasedRouting"
    http_listener_name                            = "api-http-listener"
    backend_address_pool_name                     = "app-service-backend-pool"
    backend_http_settings_name                    = "${var.apis[0]}-http-setting-${terraform.workspace}"
    url_path_map_name                             = "agw-url-path-map-${terraform.workspace}"  
  }
}




