locals {
    nsg_rules = {
        allow_management_inbound = {
            description = "Allow inbound management traffic"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = "*"
            }
            destination = {
                port    = ""
                range   = ["9000", "9003", "1438", "1440", "1452"]
                prefix  = "*"
            }
            access      = "Allow"
            priority    = 100
            direction   = "Inbound"
        }
        allow_misubnet_inbound = {
            description = "Allow inbound traffic inside the subnet"
            protocol    = "*"
            source = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            destination = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            access      = "Allow"
            priority    = 200
            direction   = "Inbound"
        }
        allow_health_probe_inbound = {
            description = "Allow health probe"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = "AzureLoadBalancer"
            }
            destination = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            access      = "Allow"
            priority    = 300
            direction   = "Inbound"
        }
        allow_tds_inbound = {
            description = "Allow access to data"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = "VirtualNetwork"
            }
            destination = {
                port    = "1433"
                range   = []
                prefix  = var.SubnetRange
            }
            access      = "Allow"
            priority    = 1000
            direction   = "Inbound"
        }
        allow_redirect_inbound = {
            description = "Allow inbound redirect traffic to Managed Instance inside the virtual network"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = "VirtualNetwork"
            }
            destination = {
                port    = "11000-11999"
                range   = []
                prefix  = var.SubnetRange
            }
            access      = "Allow"
            priority    = 1100
            direction   = "Inbound"
        }
        allow_geodr_inbound = {
            description = "Allow inbound geodr traffic inside the virtual network"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = "VirtualNetwork"
            }
            destination = {
                port    = "5022"
                range   = []
                prefix  = var.SubnetRange
            }
            access      = "Allow"
            priority    = 1200
            direction   = "Inbound"
        }
        public_endpoint_inbound_AzureCloud = {
            description = "Controls inbound traffic to the Managed Instance via Public Endpoint"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = "AzureCloud"
            }
            destination = {
                port    = ""
                range   = ["3342","1433"]
                prefix  = var.SubnetRange
            }
            access      = var.PublicEndpoint == true ? "Allow" : "Deny"
            priority    = 1250
            direction   = "Inbound"
        }
        public_endpoint_inbound = {
            description = "Controls inbound traffic to the Managed Instance via Public Endpoint"
            protocol    = "*"
            source = {
                port    = "*"
                range   = []
                prefix  = "*"
            }
            destination = {
                port    = "3342"
                range   = []
                prefix  = "*"
            }
            access      = var.PublicEndpoint == true ? "Allow" : "Deny"
            priority    = 1300
            direction   = "Inbound"
        }
        deny_all_inbound = {
            description = "Deny all other inbound traffic"
            protocol    = "*"
            source = {
                port    = "*"
                range   = []
                prefix  = "*"
            }
            destination = {
                port    = "*"
                range   = []
                prefix  = "*"
            }
            access      = "Deny"
            priority    = 4096
            direction   = "Inbound"
        }
        allow_management_outbound = {
            description = "Allow outbound management traffic"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            destination = {
                port    = ""
                range   = ["443","12000"]
                prefix  = "AzureCloud"
            }
            access      = "Allow"
            priority    = 100
            direction   = "Outbound"
        }
        allow_misubnet_outbound = {
            description = "Allow outbound traffic inside the subnet"
            protocol    = "*"
            source = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            destination = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            access      = "Allow"
            priority    = 200
            direction   = "Outbound"
        }
        allow_linkedserver_outbound = {
            description = "Allow outbound linkedserver traffic inside the virtual network"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            destination = {
                port    = "1433"
                range   = []
                prefix  = "VirtualNetwork"
            }
            access      = "Allow"
            priority    = 1000
            direction   = "Outbound"
        }
        allow_redirect_outbound = {
            description = "Allow outbound redirect traffic to Managed Instance inside the virtual network"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            destination = {
                port    = "11000-11999"
                range   = []
                prefix  = "VirtualNetwork"
            }
            access      = "Allow"
            priority    = 1100
            direction   = "Outbound"
        }
        allow_geodr_outbound = {
            description = "Allow outbound geodr traffic inside the virtual network"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            destination = {
                port    = "5022"
                range   = []
                prefix  = "VirtualNetwork"
            }
            access      = "Allow"
            priority    = 1200
            direction   = "Outbound"
        }
        allow_adf_outbound = {
            description = "Allow outbound adf traffic inside the virtual network"
            protocol    = "Tcp"
            source = {
                port    = "*"
                range   = []
                prefix  = var.SubnetRange
            }
            destination = {
                port    = ""
                range   = ["3342","1433"]
                prefix  = "AzureCloud"
            }
            access      = "Allow"
            priority    = 1300
            direction   = "Outbound"
        }
        deny_all_outbound = {
            description = "Deny all other outbound traffic"
            protocol    = "*"
            source = {
                port    = "*"
                range   = []
                prefix  = "*"
            }
            destination = {
                port    = "*"
                range   = []
                prefix  = "*"
            }
            access      = "Deny"
            priority    = 4096
            direction   = "Outbound"
        }
    }
}
