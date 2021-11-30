resource "azurerm_recovery_services_protection_policy_vm" "chef-asr-policy" {
  name                = "${local.asr_policy_name}"
  resource_group_name = "${azurerm_resource_group.app-rg.name}"
  recovery_vault_name = "${azurerm_recovery_services_vault.chef-vault.name}"

  backup = {
    frequency = "${var.asr_policy_frequency}"
    time      = "${var.asr_policy_time}"
  
  }

  retention_daily = {
    count = "${var.asr_daily_retention}"
  }

  retention_weekly = {
    count    = 4
    weekdays = ["Saturday","Sunday", "Monday","Tuesday","Wednesday", "Thursday","Friday"]
  }

  retention_monthly = {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }
}
