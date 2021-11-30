locals {
	tempTags = {
		terraformed	= "yes"
		environment	= var.Environment
		project			= var.Project
		location		= var.Location
	}
	tags = merge(local.tempTags, var.Tags)
}
