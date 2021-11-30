locals {
    tags = {
        project = "Aspire"
        environment = "${terraform.workspace}"
        app = "aspire"
        contact = "Stephen Aggett"
        contact_details = "stephen.aggett@britinsurance.com"
        costcentre = "N37"
        description = "Aspire Infrastructure"
        location = "${var.azure_region}"
        terraformed = "yes"
    }
}