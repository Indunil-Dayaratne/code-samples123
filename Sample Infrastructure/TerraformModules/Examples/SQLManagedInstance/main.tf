module "main" {
  source = "./Modules/SQLManagedInstance"	
    
    Location			= var.Location
	ResourceGroup		= var.ResourceGroup["VirtualMachine"]
	AdminPassword   	= var.VmPassword
	NetworkRG 			= var.ResourceGroup["VirtualNetwork"]
	VNet 				= var.Network["VirtualNetwork"]
	Subnet 				= var.Network["Subnet"]
	Nsg 				= var.Network["NetworkSecurityGroup"]
	NsgRG 				= var.ResourceGroup["NetworkSecurityGroup"]
	Tags 				= local.tags
	DomainPassword	    = var.DomainPassword
	Project 			= var.Project
	Environment 		= var.Environment
}    