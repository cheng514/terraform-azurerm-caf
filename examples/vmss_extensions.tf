module "vmss_extension_microsoft_azure_domainjoin" {
  source     = "../modules/compute/virtual_machine_scale_set_extensions"
  depends_on = [module.example]

  for_each = {
    for key, value in try(var.virtual_machine_scale_sets, {}) : key => value
    if try(value.virtual_machine_scale_set_extensions.microsoft_azure_domainjoin, null) != null
  }

  client_config                = module.example.client_config
  virtual_machine_scale_set_id = module.example.virtual_machine_scale_sets[each.key].id
  extension                    = each.value.virtual_machine_scale_set_extensions.microsoft_azure_domainjoin
  extension_name               = "microsoft_azure_domainJoin"
  keyvaults                    = tomap({ (var.landingzone.key) = module.example.keyvaults })
}


module "vmss_extension_custom_scriptextension" {
  source     = "../modules/compute/virtual_machine_scale_set_extensions"
  depends_on = [module.example]

  for_each = {
    for key, value in try(var.virtual_machine_scale_sets, {}) : key => value
    if try(value.virtual_machine_scale_set_extensions.custom_script, null) != null
  }

  client_config                     = module.example.client_config
  virtual_machine_scale_set_id      = module.example.virtual_machine_scale_sets[each.key].id
  extension                         = each.value.virtual_machine_scale_set_extensions.custom_script
  extension_name                    = "custom_script"
  managed_identities                = tomap({ (var.landingzone.key) = module.example.managed_identities })
  storage_accounts                  = tomap({ (var.landingzone.key) = module.example.storage_accounts })
  virtual_machine_scale_set_os_type = module.example.virtual_machine_scale_sets[each.key].os_type
}

module "vmss_extension_microsoft_monitoring_agent" {
  source     = "../modules/compute/virtual_machine_scale_set_extensions"
  depends_on = [module.example]

  for_each = {
    for key, value in try(var.virtual_machine_scale_sets, {}) : key => value
    if try(value.virtual_machine_scale_set_extensions.microsoft_monitoring_agent, null) != null
  }
  extension_name                    = "microsoft_monitoring_agent"
  extension                         = each.value.virtual_machine_scale_set_extensions.microsoft_monitoring_agent
  client_config                     = module.example.client_config
  virtual_machine_scale_set_id      = module.example.virtual_machine_scale_sets[each.key].id
  virtual_machine_scale_set_os_type = module.example.virtual_machine_scale_sets[each.key].os_type
  log_analytics_workspaces = tomap(
    {
      (var.landingzone.key) = module.example.log_analytics
    }
  )
}

module "vmss_extension_dependency_agent" {
  source     = "../modules/compute/virtual_machine_scale_set_extensions"
  depends_on = [module.example, module.vmss_extension_microsoft_monitoring_agent]

  for_each = {
    for key, value in try(var.virtual_machine_scale_sets, {}) : key => value
    if try(value.virtual_machine_scale_set_extensions.dependency_agent, null) != null
  }
  extension_name                              = "dependency_agent"
  extension                                   = each.value.virtual_machine_scale_set_extensions.dependency_agent
  client_config                               = module.example.client_config
  virtual_machine_scale_set_id                = module.example.virtual_machine_scale_sets[each.key].id
  virtual_machine_scale_set_os_type = module.example.virtual_machine_scale_sets[each.key].os_type
  microsoft_monitoring_agent_extension_name   = "microsoft_monitoring_agent"
}