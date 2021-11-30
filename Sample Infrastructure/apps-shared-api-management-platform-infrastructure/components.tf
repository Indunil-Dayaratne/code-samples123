// Refer to Resource Group
data "azurerm_resource_group" "rg" {
  name                              = local.resource_group_name
}

data "azurerm_key_vault" "kv" {
  name                = local.kv_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_api_management" "apim" {
  count               = local.apimresource
  name                = local.apim_name
  location            = var.azure_region
  resource_group_name = data.azurerm_resource_group.rg.name
  publisher_name      = "Brit Group Services"
  publisher_email     = var.contact_email  

  sku_name = "Premium_1"

  identity        {
                    type = "SystemAssigned"
                  }

  additional_location {
                        location = var.azure_region_dr
                      }
                      
}

data "azurerm_api_management" "apim" {
  count               = local.apimdatasource
  name                = local.apim_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_api_management_api" "api" {
  count                 = length(var.apis)
  name                  = var.apis[count.index].Name
  resource_group_name   = data.azurerm_resource_group.rg.name
  api_management_name   = local.apimresource == "1" ? azurerm_api_management.apim[0].name : data.azurerm_api_management.apim[0].name
  revision              = "1"
  subscription_required = false
  display_name          = var.apis[count.index].Name
  path                  = var.apis[count.index].Name
  protocols             = ["https"]
  service_url           = var.apis[count.index].PrimaryBaseUrl

  import {
    content_format = var.apis[count.index].APIDefinitionFormat
    content_value  = var.apis[count.index].SwaggerUrl
  }
}

resource "azurerm_api_management_api_policy" "dr" {
  count               = length(var.apis)
  api_name            = element(azurerm_api_management_api.api.*.name, count.index)
  api_management_name = local.apimresource == "1" ? azurerm_api_management.apim[0].name : data.azurerm_api_management.apim[0].name
  resource_group_name = data.azurerm_resource_group.rg.name

  xml_content = <<XML
<policies>
    <inbound>
        <cors>
            <allowed-origins>
                <origin>${var.apis[count.index].Cors}</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
                <method>PATCH</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
        </cors>
        <rewrite-uri template="@(context.Operation.UrlTemplate.Replace("${var.apis[count.index].RewriteUrl}", ""))" />
        <choose>
            <when condition="@("${var.azure_region}".Equals(context.Deployment.Region, StringComparison.OrdinalIgnoreCase))">
            <set-backend-service base-url="${var.apis[count.index].PrimaryBaseUrl}" />
                <cache-lookup-value key="${var.apis[count.index].Name}-${var.azure_short_region}-down-cache-key" default-value="@(false)" variable-name="${var.apis[count.index].Name}-${var.azure_short_region}-down" />
                <choose>
                    <when condition="@((bool)context.Variables["${var.apis[count.index].Name}-${var.azure_short_region}-down"])">
                        <set-backend-service base-url="${var.apis[count.index].SecondaryBaseUrl}" />
                    </when>
                    <otherwise>
                        <send-request ignore-error="true" timeout="30" response-variable-name="${var.apis[count.index].Name}-${var.azure_short_region}-response-status" mode="new">
                            <set-url>${var.apis[count.index].PrimaryBaseUrl}</set-url>
                            <set-method>GET</set-method>
                            <set-header name="Authorization" exists-action="override">
                                <value>@(context.Request.Headers.GetValueOrDefault("Authorization","scheme param"))</value>
                            </set-header>
                        </send-request>
                        <choose>
                            <when condition="@(context.Variables.GetValueOrDefault<IResponse>("${var.apis[count.index].Name}-${var.azure_short_region}-response-status").StatusCode == 503 || context.Variables.GetValueOrDefault<IResponse>("${var.apis[count.index].Name}-${var.azure_short_region}-response-status").StatusCode == 403 )">
                                <cache-store-value key="${var.apis[count.index].Name}-${var.azure_short_region}-down-cache-key" value="@(true)" duration="30" />
                                <cache-lookup-value key="${var.apis[count.index].Name}-${var.azure_short_region}-down-cache-key" default-value="@(false)" variable-name="${var.apis[count.index].Name}-${var.azure_short_region}-down" />
                                <set-backend-service base-url="${var.apis[count.index].SecondaryBaseUrl}" />
                            </when>
                        </choose>
                    </otherwise>
                </choose>
            </when>
            <when condition="@("${var.azure_region_dr}".Equals(context.Deployment.Region, StringComparison.OrdinalIgnoreCase))">
                <set-backend-service base-url="${var.apis[count.index].SecondaryBaseUrl}" />
                <cache-lookup-value key="${var.apis[count.index].Name}-${var.azure_short_region_dr}-down-cache-key" default-value="@(false)" variable-name="${var.apis[count.index].Name}-${var.azure_short_region_dr}-down" />
                <choose>
                    <when condition="@((bool)context.Variables["${var.apis[count.index].Name}-${var.azure_short_region_dr}-down"])">
                        <set-backend-service base-url="${var.apis[count.index].PrimaryBaseUrl}" />
                    </when>
                    <otherwise>
                        <send-request ignore-error="true" timeout="30" response-variable-name="${var.apis[count.index].Name}-${var.azure_short_region_dr}-response-status" mode="new">
                            <set-url>${var.apis[count.index].SecondaryBaseUrl}</set-url>
                            <set-method>GET</set-method>
                            <set-header name="Authorization" exists-action="override">
                                <value>@(context.Request.Headers.GetValueOrDefault("Authorization","scheme param"))</value>
                            </set-header>
                        </send-request>
                        <choose>
                            <when condition="@(context.Variables.GetValueOrDefault<IResponse>("${var.apis[count.index].Name}-${var.azure_short_region_dr}-response-status").StatusCode == 503 || context.Variables.GetValueOrDefault<IResponse>("${var.apis[count.index].Name}-${var.azure_short_region_dr}-response-status").StatusCode == 403)">
                                <cache-store-value key="${var.apis[count.index].Name}-${var.azure_short_region_dr}-down-cache-key" value="@(true)" duration="30" />
                                <cache-lookup-value key="${var.apis[count.index].Name}-${var.azure_short_region_dr}-down-cache-key" default-value="@(false)" variable-name="${var.apis[count.index].Name}-${var.azure_short_region_dr}-down" />
                                <set-backend-service base-url="${var.apis[count.index].PrimaryBaseUrl}" />
                            </when>
                        </choose>
                    </otherwise>
                </choose>
            </when>
        </choose>
  </inbound>
  <backend>
      <base />
  </backend>
  <outbound>
      <set-header name="X-Frame-Options" exists-action="override">    
            <value>deny</value>    
        </set-header>    
        <set-header name="X-Content-Type-Options" exists-action="override">    
            <value>nosniff</value>    
        </set-header>      
        <set-header name="X-XSS-Protection" exists-action="override">    
            <value>1; mode=block</value>    
        </set-header> 		
        <set-header name="Strict-Transport-Security" exists-action="override">    
            <value>max-age=63072000; includeSubDomains; preload</value>    
        </set-header>    
  </outbound>
  <on-error>
      <base />
  </on-error>
</policies>
XML
}

resource "azurerm_key_vault_access_policy" "cert-access" {
  count               = local.apimresource
  key_vault_id = data.azurerm_key_vault.kv.id

  tenant_id = var.tenant_id
  object_id = azurerm_api_management.apim[0].identity[0].principal_id

  certificate_permissions = [
    "get",
    "list"
  ]

  secret_permissions = [
    "get",
    "list"
  ]

}



