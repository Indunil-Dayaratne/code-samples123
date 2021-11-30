variable "Network" {
    type = object({
        Vnet = object({
            Name = string
            ResourceGroup = string
        })
        RouteTable = object({
            Name = string
            ResourceGroup = string
        })
        Nsg = object({
            Name = string
            ResourceGroup = string
        })
        //the name of the subnet that the app service must belong to for regional vnet integration to work. Only one subnet per app service plan can be used for this purpose.
        AppServiceSubnetName = string
        SubnetCidr = string
    })
}

variable "Network_Dr" {
    type = object({
        Vnet = object({
            Name = string
            ResourceGroup = string
        })
        
        AppServiceSubnetName = string
    })
}

variable "SqlVm" {
    type = object({
        Size = string
        Sku = string
    })
}

variable "KeyVault" {
    type = object({
        Name = string
        ResourceGroup = string
    })
}

variable "AppServicePlan" {
    type = object({
        Name = string
        ResourceGroup = string
    })
}

variable "AppServicePlanDr" {
    type = object({
        Name = string
        ResourceGroup = string
    })
}

variable "ReplyUrls" {
	type =  list(string)
}

variable "DrResource" {
    type = object({
        ResourceCount = number
    })
}

variable "cors" {
	type =  list(string)
}

variable "apim" {
  type = object({
    resource_group = string
    name = string
    base_url = string
    location = string
    location_dr = string
    region = string
    region_dr = string
    spgateway_webapp_name = string
    spgateway_webapp_name_dr = string
    swagger_resource_group_name = string
    swagger_key_vault_name = string
  })
}