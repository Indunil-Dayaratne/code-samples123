platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-nonprod"
platform_state_storage_account_name="terraformukwnonprod"
platform_state_resource_group_name = "terraform-rg-ukw-nonprod"

tenant_id = "8cee18df-5e2a-4664-8d07-0566ffea6dcd"
spn_app_id = "3d88a81a-1f2f-47a3-b5ac-acd03cd2142b"
spn_object_id = "0b497959-78fe-419f-83fe-8a8608a83443"
subscription_id = "b88ff083-a2b3-420a-bb38-b4c4ee5a28ec"

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

environment_type = "nonprod"

azure_short_region_dr = "ukw"
azure_region_dr = "UK West"

apis = [{ 
                Name = "britcache-eclipse-chg", 
                ResourceGroup = "uwac-britcache-rg-uks-tst", 
                PrimaryBaseUrl = "https://britcache-api-eclipse-func-tst.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://britcache-api-eclipse-func-tst.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-tst.azurewebsites.net/api/swagger/json/britcacheeclipse", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/v2/",
                Cors="https://abz.com"
        },
        { 
                Name = "britcache-mds-chg", 
                ResourceGroup = "uwac-britcache-rg-uks-tst", 
                PrimaryBaseUrl = "https://britcache-api-mds-func-tst.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://britcache-api-mds-func-tst.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-tst.azurewebsites.net/api/swagger/json/britcachemds", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/v2/" ,
                Cors="https://abz.com"
        },
        { 
                Name = "britcache-broker-chg", 
                ResourceGroup = "uwac-britcache-rg-uks-tst", 
                PrimaryBaseUrl = "https://britcache-api-broker-func-tst.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://britcache-api-broker-func-tst.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-tst.azurewebsites.net/api/swagger/json/britcachebroker", 
                FrontEnd = "api-test.britinsurance.com" , 
                RewriteUrl="api/v1/",
                Cors="https://abz.com"
        },
        { 
                Name = "britcache-policy-chg", 
                ResourceGroup = "uwac-reference-creation-rg-uks-uat", 
                PrimaryBaseUrl = "https://britcache-api-britpolicy-func-uks-uat.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://britcache-api-britpolicy-func-uks-uat.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-uat.azurewebsites.net/api/swagger/json/britcachepolicy", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/v1/",
                Cors="https://abz.com"
        },
        {       
                Name = "keas-chg", 
                ResourceGroup = "ki-services-rg-uks-chg", 
                PrimaryBaseUrl = "https://ki-keas-api-func-uks-chg.azurewebsites.net/api/", 
                SecondaryBaseUrl = "https://ki-keas-api-func-uks-chg.azurewebsites.net/api/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/keas", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/" ,
                Cors="https://abz.com"
        },
        { 
                Name = "dnb-chg", 
                ResourceGroup = "uwac-reference-creation-rg-uks-uat", 
                PrimaryBaseUrl = "https://dnb-api-func-uks-uat.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://dnb-api-func-uks-uat.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-uat.azurewebsites.net/api/swagger/json/dnb", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/v1/",
                Cors="https://abz.com" 
        },
        {       Name = "dowjones-chg", 
                ResourceGroup = "uwac-reference-creation-rg-uks-uat", 
                PrimaryBaseUrl = "https://dow-jones-api-func-uks-uat.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://dow-jones-api-func-uks-uat.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-uat.azurewebsites.net/api/swagger/json/dowjones", 
                FrontEnd = "api-test.britinsurance.com" , 
                RewriteUrl="api/v1/",
                Cors="https://abz.com"
        },
        { 
                Name = "ki-quote-chg", 
                ResourceGroup = "ki-services-rg-uks-chg", 
                PrimaryBaseUrl = "https://ki-quote-api-webapp-uks-chg.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://ki-quote-api-webapp-uks-chg.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/kiquote", 
                FrontEnd = "api-test.ki-insurance.com", 
                RewriteUrl="api/v2/" ,
                Cors="https://opus-uat"
        },
        { 
                Name = "ki-pricing-chg", 
                ResourceGroup = "ki-services-rg-uks-chg", 
                PrimaryBaseUrl = "https://ki-pricing-api-func-uks-chg.azurewebsites.net/api/v2/", 
                SecondaryBaseUrl = "https://ki-pricing-api-func-uks-chg.azurewebsites.net/api/v2/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/pricing", 
                FrontEnd = "api-test.ki-insurance.com", 
                RewriteUrl="api/v2/" ,
                Cors="https://abz.com"
        },
        { 
                Name = "ki-cat-modelling-chg", 
                ResourceGroup = "ki-services-rg-uks-chg", 
                PrimaryBaseUrl = "https://ki-cat-modelling-api-func-uks-chg.azurewebsites.net/api/v1/", 
                SecondaryBaseUrl = "https://ki-cat-modelling-api-func-uks-chg.azurewebsites.net/api/v1/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/catmodelling", 
                FrontEnd = "api-test.ki-insurance.com", 
                RewriteUrl="api/v1/" ,
                Cors="https://abz.com"
        },				
        { 
                Name = "ext-britcache-eclipse-chg", 
                ResourceGroup = "uwac-ki-rg-uks-tst", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/britcache/eclipse/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/britcache/eclipse/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-tst.azurewebsites.net/api/swagger/json/britcacheeclipse", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/v2/",
                Cors="https://abz.com"        },
        { 
                Name = "ext-britcache-mds-chg", 
                ResourceGroup = "uwac-ki-rg-uks-tst", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/britcache/mds/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/britcache/mds/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-tst.azurewebsites.net/api/swagger/json/britcachemds", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/v2/" ,
                Cors="https://abz.com"
        },
        { 
                Name = "ext-britcache-broker-chg", 
                ResourceGroup = "uwac-ki-rg-uks-tst", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/britcache/broker/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/britcache/broker/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-tst.azurewebsites.net/api/swagger/json/britcachebroker", 
                FrontEnd = "api-test.britinsurance.com", 
                RewriteUrl="api/v1/" ,
                Cors="https://abz.com"
        },
        {       
                Name = "ext-dnb-chg", 
                ResourceGroup = "uwac-ki-rg-uks-uat", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/dnb/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/dnb/", 
                APIDefinitionFormat = "swagger-link-json", 
                SwaggerUrl = "https://swagger-api-func-uks-uat.azurewebsites.net/api/swagger/json/dnb", 
                FrontEnd = "api-test.britinsurance.com" , 
                RewriteUrl="api/v1/",
                Cors="https://abz.com"
        },
        {       
                Name = "ext-ki-quote-chg", 
                ResourceGroup = "uwac-ki-rg-uks-chg", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/quote/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/quote/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/kiquote", 
                FrontEnd = "api-test.ki-insurance.com" , 
                RewriteUrl="api/v2/",
                Cors="https://abz.com"
        },
        {       
                Name = "ext-ki-pricing-chg", 
                ResourceGroup = "uwac-ki-rg-uks-chg", 
                PrimaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/pricing/", 
                SecondaryBaseUrl = "https://ki-interface-api-func-uks-chg.azurewebsites.net/api/v1/pricing/", 
                APIDefinitionFormat = "openapi+json-link", 
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/pricing", 
                FrontEnd = "api-test.ki-insurance.com", 
                RewriteUrl="api/v2/" ,
                Cors="https://abz.com"
        },
        { 
                 Name = "most-material-chg",
                 ResourceGroup = "containers-rg-uks-chg",
                 PrimaryBaseUrl = "https://mostmaterial-api-webapp-uks-chg.azurewebsites.net/api/v1/",
                 SecondaryBaseUrl = "https://mostmaterial-api-webapp-uks-chg.azurewebsites.net/api/v1/",
                 APIDefinitionFormat = "swagger-link-json",
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/mostmaterial",
                FrontEnd = "api-test.ki-insurance.com",
                RewriteUrl="api/v1/",
                Cors="https://abz.com"
        },
        { 
                Name = "adjustment-chg",
                ResourceGroup = "containers-rg-uks-chg",
                PrimaryBaseUrl = "https://adjustment-layer-api-webapp-uks-chg.azurewebsites.net/api/v1/",
                SecondaryBaseUrl = "https://adjustment-layer-api-webapp-uks-chg.azurewebsites.net/api/v1/",
                APIDefinitionFormat = "swagger-link-json",
                SwaggerUrl = "https://swagger-api-func-uks-chg.azurewebsites.net/api/swagger/json/adjustmentlayer",
                FrontEnd = "api-test.ki-insurance.com",
                RewriteUrl="api/v1/",
                Cors="https://abz.com"
        }]