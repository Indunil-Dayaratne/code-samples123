locals {
    resource_group_name = "${lookup(local.tags,"app")}-rg-${terraform.workspace}"
    disk_name_main_os_1 = "${lookup(local.tags,"app")}-osdisk-01-${var.azure_short_region}-${terraform.workspace}"
    disk_name_main_os_2 = "${lookup(local.tags,"app")}-osdisk-02-${var.azure_short_region}-${terraform.workspace}"

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