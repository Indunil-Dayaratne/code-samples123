data "azurerm_resource_group" "rg" {
  name = var.apim.resource_group_name
}

data "azurerm_api_management" "apim" {
  name                = var.apim.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_api_management_api" "api" {
  name                  = var.api.name
  resource_group_name   = data.azurerm_resource_group.rg.name
  api_management_name   = data.azurerm_api_management.apim.name
  revision              = "1"
  subscription_required = false
  display_name          = var.api.name
  path                  = var.api.relative_path
  protocols             = ["https"]
  service_url           = var.api.primary_base_url

  import {
    content_format = var.api.content_format
    content_value  = var.api.swagger_url
  }
}

resource "azurerm_api_management_api_policy" "dr" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = data.azurerm_api_management.apim.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_key_vault_secret.swagger_url_secret, azurerm_key_vault_secret.client_id_secret]

  xml_content = <<XML
<policies>
    <inbound>
%{ if length(var.api.cors_origins) > 0 ~}  
        <cors allow-credentials = "true">
            <allowed-origins>
%{ for origin in var.api.cors_origins ~}
                <origin>${origin}</origin>
%{ endfor ~}
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
%{ endif ~}
%{ if length(var.api.rewrite_url) > 0 ~}  
        <rewrite-uri template="@(context.Operation.UrlTemplate.Replace("${var.api.rewrite_url}", ""))" />
%{ endif ~}
        <choose>
            <when condition="@("${var.region.location}".Equals(context.Deployment.Region, StringComparison.OrdinalIgnoreCase))">
            <set-backend-service base-url="${var.api.primary_base_url}" />
                <cache-lookup-value key="${var.api.name}-${var.region.location_short_name}-down-cache-key" default-value="@(false)" variable-name="${var.api.name}-${var.region.location_short_name}-down" />
                <choose>
                    <when condition="@((bool)context.Variables["${var.api.name}-${var.region.location_short_name}-down"])">
                        <set-backend-service base-url="${var.api.secondary_base_url}" />
                    </when>
                    <otherwise>
                        <send-request ignore-error="true" timeout="30" response-variable-name="${var.api.name}-${var.region.location_short_name}-response-status" mode="new">
                            <set-url>${var.api.primary_base_url}</set-url>
                            <set-method>GET</set-method>
                            <set-header name="Authorization" exists-action="override">
                                <value>@(context.Request.Headers.GetValueOrDefault("Authorization","scheme param"))</value>
                            </set-header>
                        </send-request>
                        <choose>
                            <when condition="@(context.Variables.GetValueOrDefault<IResponse>("${var.api.name}-${var.region.location_short_name}-response-status").StatusCode >= 500 || context.Variables.GetValueOrDefault<IResponse>("${var.api.name}-${var.region.location_short_name}-response-status").StatusCode == 403 )">
                                <cache-store-value key="${var.api.name}-${var.region.location_short_name}-down-cache-key" value="@(true)" duration="30" />
                                <cache-lookup-value key="${var.api.name}-${var.region.location_short_name}-down-cache-key" default-value="@(false)" variable-name="${var.api.name}-${var.region.location_short_name}-down" />
                                <set-backend-service base-url="${var.api.secondary_base_url}" />
                            </when>
                        </choose>
                    </otherwise>
                </choose>
            </when>
            <otherwise>
                <set-backend-service base-url="${var.api.secondary_base_url}" />
                <cache-lookup-value key="${var.api.name}-${var.region.location_short_name_dr}-down-cache-key" default-value="@(false)" variable-name="${var.api.name}-${var.region.location_short_name_dr}-down" />
                <choose>
                    <when condition="@((bool)context.Variables["${var.api.name}-${var.region.location_short_name_dr}-down"])">
                        <set-backend-service base-url="${var.api.primary_base_url}" />
                    </when>
                    <otherwise>
                        <send-request ignore-error="true" timeout="30" response-variable-name="${var.api.name}-${var.region.location_short_name_dr}-response-status" mode="new">
                            <set-url>${var.api.secondary_base_url}</set-url>
                            <set-method>GET</set-method>
                            <set-header name="Authorization" exists-action="override">
                                <value>@(context.Request.Headers.GetValueOrDefault("Authorization","scheme param"))</value>
                            </set-header>
                        </send-request>
                        <choose>
                            <when condition="@(context.Variables.GetValueOrDefault<IResponse>("${var.api.name}-${var.region.location_short_name_dr}-response-status").StatusCode >= 500 || context.Variables.GetValueOrDefault<IResponse>("${var.api.name}-${var.region.location_short_name_dr}-response-status").StatusCode == 403)">
                                <cache-store-value key="${var.api.name}-${var.region.location_short_name_dr}-down-cache-key" value="@(true)" duration="30" />
                                <cache-lookup-value key="${var.api.name}-${var.region.location_short_name_dr}-down-cache-key" default-value="@(false)" variable-name="${var.api.name}-${var.region.location_short_name_dr}-down" />
                                <set-backend-service base-url="${var.api.primary_base_url}" />
                            </when>
                        </choose>
                    </otherwise>
                </choose>
            </otherwise>
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

resource "null_resource" "update_open_api_specification" {
  provisioner "local-exec" {
    command = ".\\update-open-api.ps1 -resourceGroupName ${data.azurerm_resource_group.rg.name} -serviceName ${data.azurerm_api_management.apim.name} -serviceUrl ${var.api.primary_base_url} -specificationUrl ${var.api.swagger_url} -apiName ${var.api.name} -apiPath  ${var.api.relative_path}"
    working_dir = path.module
    interpreter = ["pwsh", "-Command"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [azurerm_api_management_api_policy.dr]
}