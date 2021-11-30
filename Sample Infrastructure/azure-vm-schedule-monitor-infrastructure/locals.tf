locals {
    resource_group_name = "${lookup(local.tags,"app")}-rg-${terraform.workspace}"
  
    tags = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
        storage = "${var.storage}"
        tablestore = "${var.tablestore}"
        contact = "${var.contact}"
        contact_details = "${var.contact_details}"
        costcentre = "${var.costcentre}"
        description = "${var.description}"
        location = "${var.azure_region}"      
    }
}