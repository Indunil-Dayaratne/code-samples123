resource "azuread_application" "val_aad" {
  name = local.validator_aad_name
  oauth2_allow_implicit_flow = true
  homepage                   = "https://${local.validator_aad_name}.azurewebsites.net"  
  reply_urls                 = concat(["https://${local.validator_aad_name}.azurewebsites.net/.auth/login/aad/callback"], var.reply_urls ) 
  identifier_uris            = ["https://${local.validator_aad_name}.azurewebsites.net"]
  available_to_other_tenants = false
}
resource "azuread_application" "map_aad" {
  name = local.mapper_aad_name
  oauth2_allow_implicit_flow = true
  homepage                   = "https://${local.mapper_aad_name}.azurewebsites.net"  
  reply_urls                 = concat(["https://${local.mapper_aad_name}.azurewebsites.net/.auth/login/aad/callback"], var.reply_urls ) 
  identifier_uris            = ["https://${local.mapper_aad_name}.azurewebsites.net"]
  available_to_other_tenants = false
}

resource "azuread_application" "api_aad" {
  name = local.api_aad_name
  oauth2_allow_implicit_flow = true
  homepage                   = "https://${local.api_aad_name}.azurewebsites.net"  
  reply_urls                 = concat(["https://${local.api_aad_name}.azurewebsites.net/.auth/login/aad/callback"], var.reply_urls ) 
  identifier_uris            = ["https://${local.api_aad_name}.azurewebsites.net"]
  available_to_other_tenants = false
}

data "azuread_application" "notify_aad" {
  name  = local.notify_aad_name
}

resource "null_resource" "script1" {
  provisioner "local-exec" {
    command = "Write-Host \"Hello World\""

 

    interpreter = ["PowerShell", "-Command"]
  }
}