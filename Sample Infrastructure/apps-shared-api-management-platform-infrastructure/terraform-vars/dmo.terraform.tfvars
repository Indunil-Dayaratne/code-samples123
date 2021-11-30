platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-prod"
platform_state_storage_account_name="terraformukwprod"
platform_state_resource_group_name = "terraform-rg-ukw-prod"

tenant_id = "8cee18df-5e2a-4664-8d07-0566ffea6dcd"
spn_app_id = "3d88a81a-1f2f-47a3-b5ac-acd03cd2142b"
spn_object_id = "0b497959-78fe-419f-83fe-8a8608a83443"
subscription_id = "97537777-853f-4194-9301-8eab79b3c259"

azure_short_region = "uks"
azure_region = "UK South"
project = "apps"
app = "shared"
app_shortname = "shared"
contact = "Ahmet Demir"
contact_details = "ext 10129"
contact_email = "ahmet.demir@britinsurance.com"
costcentre = "N37"
description = "API Management"

subcategory = "shared-services"

environment_type = "prod"

azure_short_region_dr = "ukw"
azure_region_dr = "UK West"

apis = [
        { 
                Name = "britcache-eclipse-dmo", ResourceGroup = "uwac-britcache-rg-uks-prd", 
                PrimaryBaseUrl = "https://britcache-api-eclipse-func-prd.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://britcache-api-eclipse-func-ukw-prd.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/britcacheeclipse", 
                FrontEnd = "api.britinsurance.com" , 
                RewriteUrl="api/v2/",
                Cors="https://abz.com"
        },
        { 
                Name = "britcache-mds-dmo", 
                ResourceGroup = "uwac-britcache-rg-uks-prd", 
                PrimaryBaseUrl = "https://britcache-api-mds-func-prd.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://britcache-api-mds-func-ukw-prd.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/britcachemds", 
                FrontEnd = "api.britinsurance.com" , 
                RewriteUrl="api/v2/",Cors="https://abz.com"
        },
        { 
                Name = "britcache-broker-dmo", 
                ResourceGroup = "uwac-britcache-rg-uks-prd", 
                PrimaryBaseUrl = "https://britcache-api-broker-func-prd.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://britcache-api-broker-func-ukw-prd.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/britcachebroker", 
                FrontEnd = "api.britinsurance.com" , 
                RewriteUrl="api/v1/",Cors="https://abz.com"
        },
        { 
                Name = "britcache-policy-dmo", 
                ResourceGroup = "uwac-reference-creation-rg-uks-prd", 
                PrimaryBaseUrl = "https://britcache-api-britpolicy-func-uks-prd.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://britcache-api-britpolicy-func-uks-prd.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "openapi+json-link",
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/britcachepolicy", 
                FrontEnd = "api.britinsurance.com", 
                RewriteUrl="api/v1/" ,Cors="https://abz.com"
        },
        { 
                Name = "keas-dmo", 
                ResourceGroup = "ki-services-rg-uks-dmo", 
                PrimaryBaseUrl = "https://ki-keas-api-func-uks-dmo.azurewebsites.net/api/", 
                SecondaryBaseUrl = "https://ki-keas-api-func-uks-dmo.azurewebsites.net/api/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/keas", 
                FrontEnd = "api.britinsurance.com", RewriteUrl="api/" ,Cors="https://abz.com"
        },
        { 
                Name = "dnb-dmo", 
                ResourceGroup = "uwac-reference-creation-rg-uks-prd", 
                PrimaryBaseUrl = "https://dnb-api-func-uks-prd.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://dnb-api-func-uks-prd.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/dnb", 
                FrontEnd = "api.britinsurance.com", 
                RewriteUrl="api/v1/" ,Cors="https://abz.com"
        },
        { 
                Name = "dowjones-dmo", 
                ResourceGroup = "uwac-reference-creation-rg-uks-prd", 
                PrimaryBaseUrl = "https://dow-jones-api-func-uks-prd.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://dow-jones-api-func-uks-prd.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/dowjones", 
                FrontEnd = "api.britinsurance.com" , 
                RewriteUrl="api/v1/",Cors="https://abz.com"
        },
        { 
                Name = "ki-quote-dmo", 
                ResourceGroup = "ki-services-rg-uks-dmo", 
                PrimaryBaseUrl = "https://ki-quote-api-webapp-uks-dmo.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://ki-quote-api-webapp-uks-dmo.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/kiquote", 
                FrontEnd = "api.ki-insurance.com", 
                RewriteUrl="api/v2/" ,Cors="https://opus-uat"
        },
        { 
                Name = "ki-pricing-dmo", 
                ResourceGroup = "ki-services-rg-uks-dmo", 
                PrimaryBaseUrl = "https://ki-pricing-api-func-uks-dmo.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://ki-pricing-api-func-uks-dmo.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/pricing", 
                FrontEnd = "api.ki-insurance.com", 
                RewriteUrl="api/v2/" ,Cors="https://abz.com"
        },
        { 
                Name = "ki-cat-modelling-dmo", 
                ResourceGroup = "ki-services-rg-uks-dmo", 
                PrimaryBaseUrl = "https://ki-cat-modelling-api-func-uks-dmo.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://ki-cat-modelling-api-func-uks-dmo.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/catmodelling", 
                FrontEnd = "api.ki-insurance.com" , 
                RewriteUrl="api/v1/",Cors="https://abz.com"
        },
        { 
                Name = "ext-britcache-eclipse-dmo", 
                ResourceGroup = "uwac-ki-rg-uks-prd", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/britcache/eclipse/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/britcache/eclipse/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/britcacheeclipse", 
                FrontEnd = "api.britinsurance.com", 
                RewriteUrl="api/v2/" ,Cors="https://abz.com"
        },
        { 
                Name = "ext-britcache-mds-dmo", 
                ResourceGroup = "uwac-ki-rg-uks-prd", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/britcache/mds/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/britcache/mds/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/britcachemds", 
                FrontEnd = "api.britinsurance.com", 
                RewriteUrl="api/v2/" ,Cors="https://abz.com"
        },
        { 
                Name = "ext-britcache-broker-dmo", 
                ResourceGroup = "uwac-ki-rg-uks-prd", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/britcache/broker/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/britcache/broker/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/britcachebroker", 
                FrontEnd = "api.britinsurance.com", 
                RewriteUrl="api/v1/" ,Cors="https://abz.com"
        },
        { 
                Name = "ext-dnb-dmo", 
                ResourceGroup = "uwac-ki-rg-uks-prd", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/dnb/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/dnb/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-prd.azurewebsites.net/api/swagger/json/dnb", 
                FrontEnd = "api.britinsurance.com", 
                RewriteUrl="api/v1/" ,Cors="https://abz.com"
        },
	{ 
                Name = "ext-ki-quote-dmo", 
                ResourceGroup = "uwac-ki-rg-uks-dmo", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/quote/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/quote/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/kiquote", 
                FrontEnd = "api.ki-insurance.com", 
                RewriteUrl="api/v2/" ,Cors="https://abz.com"
        },
        { 
                Name = "ext-ki-pricing-dmo", 
                ResourceGroup = "uwac-ki-rg-uks-dmo", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/pricing/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-dmo.azurewebsites.net/api/v1/pricing/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/pricing", 
                FrontEnd = "api.ki-insurance.com", 
                RewriteUrl="api/v2/" ,Cors="https://abz.com"
        },
        { 
                Name = "most-material-dmo", 
                ResourceGroup = "containers-rg-uks-dmo",
                PrimaryBaseUrl = "https://mostmaterial-api-webapp-uks-dmo.azurewebsites.net/api/v1/",
                SecondaryBaseUrl = "https://mostmaterial-api-webapp-uks-dmo.azurewebsites.net/api/v1/",
                APIDefinitionFormat = "swagger-link-json",
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/mostmaterial",
                FrontEnd = "api.ki-insurance.com",
                RewriteUrl="api/v1/",
                Cors="https://abz.com"
        },
        {
                Name = "adjustment-dmo", 
                ResourceGroup = "containers-rg-uks-dmo", 
                PrimaryBaseUrl = "https://adjustment-layer-api-webapp-uks-dmo.azurewebsites.net/api/v1/",
                SecondaryBaseUrl = "https://adjustment-layer-api-webapp-uks-dmo.azurewebsites.net/api/v1/",
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-dmo.azurewebsites.net/api/swagger/json/adjustmentlayer",
                FrontEnd = "api.ki-insurance.com", 
                RewriteUrl="api/v1/",
                Cors="https://abz.com" 
        }	    
       ]