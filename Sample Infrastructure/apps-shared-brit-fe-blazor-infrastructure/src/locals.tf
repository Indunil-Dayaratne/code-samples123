locals {
  project_name = "digital-brit-ui"

  tags = {
      environment = terraform.workspace
      app = "digital-brit-ui"
	    project = "Digital Brit"
      contact = "IT"
      contact_details = "ServiceDesk@britinsurance.com"
      costcentre = "P99"
      description = "Digital Brit UI"
      location = var.azure_region   
      project_subcategory = "DB-PaaS"
      business_name = "Digital-Brit-UI"
      application = "digital-brit-ui"
  }

  tags_dr = merge(local.tags, { location = var.azure_region_dr })

  contraction = {
    resource_group = "rg"
    app_service = "app"
    app_service_plan = "appsp"
    app_insights = "appins"
    key_vault = "kv"
  }

  resource_group_name = "shared-${local.project_name}-${local.contraction.resource_group}"
  appsp_name          = "shared-${local.project_name}-${local.contraction.app_service_plan}"

  aad_issuer = "https://sts.windows.net/8cee18df-5e2a-4664-8d07-0566ffea6dcd"
}