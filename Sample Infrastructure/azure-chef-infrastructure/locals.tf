locals {
    resource_group_name = "${lookup(local.tags,"app")}-rg-${terraform.workspace}"
    asr_name = "${lookup(local.tags,"app")}-asr-${data.terraform_remote_state.platform.platform_short_region}-${terraform.workspace}"
    asr_policy_name = "${lookup(local.tags,"app")}-asr-policy-${data.terraform_remote_state.platform.platform_short_region}-${terraform.workspace}"

    tags = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
        appname = "${var.appname}"
        appchefsupermkt = "${var.appchefsupermkt}"
        contact = "${var.contact}"
        contact_details = "${var.contact_details}"
        costcentre = "${var.costcentre}"
        description = "${var.description}"
        location = "${var.azure_region}"      
    }
}