locals {
    resource_group_name = "rg-${terraform.workspace}-${var.app}-${var.azure_short_region}-01"
    storage_account_name = "${terraform.workspace}esbstore"
    namespace_name = "${terraform.workspace}-esb-uks-svcbus"
    tags = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
        contact = "${var.contact}"
        contact_details = "${var.contact_details}"
        costcentre = "${var.costcentre}"
        description = "${var.description}"
        location = "${var.azure_region}"    
    }   

}

