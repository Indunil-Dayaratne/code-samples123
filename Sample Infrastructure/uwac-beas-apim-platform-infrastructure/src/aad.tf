data "azuread_application" "api_aad" {
  display_name = local.api_aad_name
}
