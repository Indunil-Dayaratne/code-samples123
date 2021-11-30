module "virtualMachine" {
	source = "../../Modules/VirtualMachine"
	
	Location				= var.Location
	ResourceGroup		= var.ResourceGroup["VirtualMachine"]
	AdminPassword 	= var.VmPassword
	Subnet 					= data.azurerm_subnet.snet.id
	Nsg 						= var.Network["NetworkSecurityGroup"]
	Tags 						= local.tags
	DomainPassword	= var.DomainPassword
	Project 				= var.Project
	Environment 		= var.Environment
}

data "azurerm_subnet" "snet" {
	name									= var.Network["Subnet"]
	resource_group_name		=	var.ResourceGroup["VirtualNetwork"]
	virtual_network_name	= var.Network["VirtualNetwork"]
}

data "azurerm_network_security_group" "nsg" {
	name								= var.Network["NetworkSecurityGroup"]
	resource_group_name	= var.ResourceGroup["NetworkSecurityGroup"]
}

# If you needed to create a fresh Resource Group, etc. you can define them here and then use interpolation syntax to reference them in the module inputs above.
