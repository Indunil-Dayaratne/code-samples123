resource "azuread_application" "func_aad" {
  name = "${local.func_aad_name}-${terraform.workspace}"
  oauth2_allow_implicit_flow = true
  homepage                   = "https://${local.func_aad_name}-${terraform.workspace}.azurewebsites.net"  
  reply_urls                 = concat(["https://${local.func_aad_name}-${terraform.workspace}.azurewebsites.net/.auth/login/aad/callback"], var.reply_urls ) 
  identifier_uris            = ["https://${local.func_aad_name}-${terraform.workspace}.azurewebsites.net"]
  available_to_other_tenants = false
}

resource "azuread_application" "web_app_aad" {
  name = "${local.web_aad_name}-${terraform.workspace}"
  oauth2_allow_implicit_flow = true
  homepage                   = "https://${local.web_app_name}-${terraform.workspace}.azurewebsites.net"  
  reply_urls                 = concat(["https://${local.web_app_name}-${terraform.workspace}.azurewebsites.net/.auth/login/aad/callback"], var.reply_urls) 
  identifier_uris            = ["https://${local.web_aad_name}-${terraform.workspace}.azurewebsites.net"]
  available_to_other_tenants = false
  app_role {
    allowed_member_types = [
      "User",
      "Application",
    ]
    description  = "Admins can manage roles and perform all task actions"
    display_name = "Admin"
    is_enabled   = true
    value        = "All"
  }
}