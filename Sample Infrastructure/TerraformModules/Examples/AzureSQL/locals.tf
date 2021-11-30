locals {
    tags = {
        project         = var.Tags.Project
        environment     = terraform.workspace
        app             = var.Tags.App
        contact         = var.Tags.Contact.Name
        contact_details = var.Tags.Contact.Email
        costcentre      = var.Tags.Costcentre
        description     = var.Tags.Description
        location        = var.Location
        terraformed     = "yes"
        repo            = var.Repo
        business_name   = var.Tags.BusinessName
    }

    region              = lower(substr(replace(var.Location," ",""),0,3))
}

