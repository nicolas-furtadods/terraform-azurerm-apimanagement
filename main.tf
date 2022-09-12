resource "azurerm_user_assigned_identity" "id-apim" {
  name                = "id-${local.naming}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
# -------------- APIM
resource "azurerm_api_management" "apim" {
  depends_on = [
    azurerm_user_assigned_identity.id-apim
  ]
  name                = "apim-${local.naming}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher.name
  publisher_email     = var.publisher.email

  sku_name             = format("%s_%s", var.sku_name, var.sku_capacity)
  virtual_network_type = var.virtual_network_type
  dynamic "virtual_network_configuration" {
    for_each = {
      for k, v in local.vnet_configuration : k => v if var.virtual_network_type == "Internal" || var.virtual_network_type == "External"
    }
    iterator = vnet
    content {
      subnet_id = vnet.value
    }
  }
  tags = var.tags
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.id-apim.id]
  }
}

resource "azurerm_api_management_custom_domain" "domains" {
  api_management_id = azurerm_api_management.apim.id
  depends_on = [
    azurerm_key_vault_access_policy.systemAssigned-apim
  ]
  dynamic "gateway" {
    for_each = {
      for k, v in var.apim_custom_domains : k => v if v.domain_key == "gateway"
    }
    iterator = domain
    content {
      host_name    = domain.value.host_name
      key_vault_id = domain.value.key_vault_id
    }
  }

  dynamic "developer_portal" {
    for_each = {
      for k, v in var.apim_custom_domains : k => v if v.domain_key == "developer_portal"
    }
    iterator = domain
    content {
      host_name    = domain.value.host_name
      key_vault_id = domain.value.key_vault_id
    }
  }

  dynamic "portal" {
    for_each = {
      for k, v in var.apim_custom_domains : k => v if v.domain_key == "portal"
    }
    iterator = domain
    content {
      host_name    = domain.value.host_name
      key_vault_id = domain.value.key_vault_id
    }
  }


  dynamic "management" {
    for_each = {
      for k, v in var.apim_custom_domains : k => v if v.domain_key == "management"
    }
    iterator = domain
    content {
      host_name    = domain.value.host_name
      key_vault_id = domain.value.key_vault_id
    }
  }

  dynamic "scm" {
    for_each = {
      for k, v in var.apim_custom_domains : k => v if v.domain_key == "scm"
    }
    iterator = domain
    content {
      host_name    = domain.value.host_name
      key_vault_id = domain.value.key_vault_id
    }
  }
}


# -------------- Access Policy
resource "azurerm_key_vault_access_policy" "systemAssigned-apim" {
  depends_on   = [azurerm_api_management.apim]
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_api_management.apim.identity[0].principal_id

  certificate_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get"
  ]

}

resource "azurerm_key_vault_access_policy" "userAssigned-apim" {
  depends_on   = [azurerm_api_management.apim]
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.id-apim.principal_id

  certificate_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get"
  ]

}

# -------------- Operations 
resource "azurerm_api_management_api" "api" {
  depends_on = [
    azurerm_api_management.apim
  ]
  for_each              = var.apis
  name                  = each.value.api_name
  resource_group_name   = var.resource_group_name
  api_management_name   = azurerm_api_management.apim.name
  revision              = each.value.revision
  display_name          = each.value.api_display_name
  path                  = each.value.path
  protocols             = each.value.protocols
  service_url           = each.value.service_url
  subscription_required = each.value.subscription
}

resource "azurerm_api_management_api_operation" "operation" {
  depends_on = [
    azurerm_api_management_api.api
  ]
  for_each            = local.operations_flattened_to_map
  operation_id        = each.value.operation_name
  api_name            = each.value.api_name
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  display_name        = each.value.operation_display_name
  method              = each.value.method
  url_template        = each.value.url_template
  description         = each.value.description

  response {
    status_code = 200
  }
}
