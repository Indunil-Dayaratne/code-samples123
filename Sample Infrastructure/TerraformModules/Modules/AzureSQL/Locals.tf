locals {
    basename             = "${var.Tags["app"]}-##-${local.region}-${terraform.workspace}"
    secondarybasename    = replace(local.basename, local.region, local.secondaryregion)
    shortname            = lower(substr(replace(local.basename, "-", ""), 0, 24))
    region               = lower(substr(replace(var.Location, " ", ""), 0, 3))
    secondaryregion      = var.SecondaryRegion != null ? lower(substr(replace(var.SecondaryRegion, " ", ""), 0, 3)) : null

    FirewallRules = {
        Azure_FW_UKS = {
            start_ip = "40.81.145.128"
            end_ip = "40.81.145.128"
        }
        Azure_FW_UKW = {
            start_ip = "40.81.125.132"
            end_ip = "40.81.125.132"
        }
        Zscaler_II = {
            start_ip = "147.161.166.0"
            end_ip = "147.161.167.255"
        }
        Zscaler_Failover = {
            start_ip = "165.225.88.0"
            end_ip = "165.225.88.255"
        }
        Zscaler_UK = {
            start_ip = "165.225.80.0"
            end_ip = "165.225.80.255"
        }
        Zscaler_US = {
            start_ip = "168.62.109.126"
            end_ip = "168.62.109.126"
        }
    }
}