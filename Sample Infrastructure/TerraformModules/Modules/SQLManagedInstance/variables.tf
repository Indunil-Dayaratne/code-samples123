variable "name" {
	type		= string
}
variable "location" {
	type		= string
	description = "Azure Region to deploy into. Defaults to 'UK South'."
	default		= "UK South"
}
variable "sku_name" {
	type		= string
}
variable "license_type" {
	type		= string
	description = "License to use for SQL MI. Defaults to 'BasePrice' to make use of Azure Hybrid Benefit pricing."
	default		= "BasePrice"
}

variable "admin_password" {
	type		= string
	description = "Password for the admin account. Username is 'cloudadmin'."
}
variable "vcores" {
	type 		= number
}
variable "storage_size" {
	type		= string
}
variable "Project" {
	type		= string
	description = "Name of the project. Used to generate names."
}
variable "Environment" {
	type		= string
	description = "Environment that is being used. Used to generate names."
}
variable "ResourceGroup" {
	type		= string
	description = "Name of the resource group where the SQL managed instance will be created."
}
variable "timezone" {
	type		= string
	default 	= "UTC"
}
variable "collation" {
	type		= string
	default		= "SQL_Latin1_General_CP1_CI_AS"
}
variable "SubnetRange" {
	type		= string
}
variable "routeTable" {
	type		= string
	default		= "platform-rt-sqlmi-uks-nonprod"
}
variable "routeTableRG" {
	type		= string
	default		= "platform-rg-uks-nonprod"
}
variable "vnetName" {
	type		= string
	description = "Name of the VNet that the VM will be attached to."
}
variable "vnetResourceGroup" {
	type		= string
	description	= "Name of the Resource Group that the VNet exists in."
}
variable "PublicEndpoint" {
	type		= bool
	description	= "Should the Managed Instance have the Public Endpoint enabled? Defaults to 'false'."
	default		= false
}
variable "tlsversion" {
	type		= string
	description	= "Minimal TLS version. Allowed values: 'None', '1.0', '1.1', '1.2'. '1.2' Recommended"
	default		= false
}
variable "Tags" {
	type		= map
	description = "Map of Tags to apply to deployed resources"
	default		= {}
}
