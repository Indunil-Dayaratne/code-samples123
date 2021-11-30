variable "Network" {
    type = object({
        Vnet = object({
            Name = string
            ResourceGroup = string
        })
        //the name of the subnet that the app service must belong to for regional vnet integration to work. Only one subnet per app service plan can be used for this purpose.
        AppServiceSubnetName = string        
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

variable "AppServicePlan_Dr" {
    type = object({
        Name = string
        ResourceGroup = string
    })
}

variable "Resource_Dr" {
    type = object({
        ResourceCount = string
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
    spredirector_webapp_name = string
    spredirector_webapp_name_dr = string
    swagger_resource_group_name = string
    swagger_key_vault_name = string
  })
}