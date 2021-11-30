platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-nonprod"
platform_state_storage_account_name="terraformukwnonprod"
platform_state_resource_group_name = "terraform-rg-ukw-nonprod"

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
costcentre = "N37"
description = "Application Gateway"

subcategory = "opus"

environment_postfix = "prd"

azure_short_region_dr = "ukw"
azure_region_dr = "UK West"

apis = ["britcache-api-ad", "britcache-api-cdp","britcache-api-cmt","britcache-api-common",
        "britcache-api-dwf","britcache-api-eclipse","britcache-api-epeer","britcache-api-ignis",
        "britcache-api-mds","britcache-api-pricing","britcache-api-query","britcache-api-referral",
        "britcache-api-tpu","britcache-api-uwauthorities","britcache-api-velocity"
        ]

api_resource_groups = ["uwac-britcache","uwac-britcache","uwac-britcache","uwac-britcache","uwac-britcache",
                       "uwac-britcache","uwac-britcache","uwac-britcache","uwac-britcache","uwac-britcache",
                       "uwac-britcache","uwac-britcache","uwac-britcache","uwac-britcache","uwac-britcache"
        ]

apiCount = "15"