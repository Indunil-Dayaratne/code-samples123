locals {
	tags = {
		project			= "platform"
		environment	= var.environment
		location		= var.location
		terraformed	= "yes"
		repo				= "PSCloudModules/TerraformModules"
	}
}