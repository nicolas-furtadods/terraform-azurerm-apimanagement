# Azure API Management
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This Terraform feature creates a standalone [Azure API Management](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts), allowing you to deploy quickly an api management service. However it does not take in account the subnet requirement to the resources.

## Version compatibility

| Module version | Terraform version | AzureRM version |
|----------------|-------------------|-----------------|
| >= 1.x.x       | 1.1.0             | >= 3.22         |

## Usage

### Global Module Configuration
```hcl
resource "azurerm_resource_group" "rg" {
  name     = "<your_rg_name>"
  location = "francecentral"
  tags = {
    "Application"        = "azuretesting",
  }
}

module "bastion" {
  source = "./terraform-azurerm-azurebastion" # Your path may be different.
  
  # Mandatory Parameters
  application         = "azuretesting"
  environment         = "poc"
  location            = "francecentral"
  resource_group_name = azurerm_resource_group.rg.name
  technical_zone      = "cm"
  tags = {
    "Application"        = "azuretesting",
  }
  subnet_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/myvnet1/subnets/mysubnet1"
  key_vault_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroup/providers/Microsoft.KeyVault/vaults/MyKeyVault"

  publisher = {
    name  = "<Name>"
    email = "<Your-Or-Distribution-List-Email"
  }

  sku_name     = "Developer"
  sku_capacity = 1

  virtual_network_type = "Internal"

  apim_custom_domains = {
    "gateway" = {
      domain_key   = "gateway"
      host_name    = "api.contoso.com"
      key_vault_id = "https://MyKeyVault.vault.azure.net/secrets/Wildcardcontoso"
    }
    "developer_portal" = {
      domain_key   = "developer_portal"
      host_name    = "portal.contoso.com"
      key_vault_id = "https://MyKeyVault.vault.azure.net/secrets/Wildcardcontoso"
    }
    "management" = {
      domain_key   = "management"
      host_name    = "management.contoso.com"
      key_vault_id = "https://MyKeyVault.vault.azure.net/secrets/Wildcardcontoso"
    }
    "scm" = {
      domain_key   = "scm"
      host_name    = "scm.contoso.com"
      key_vault_id = "https://MyKeyVault.vault.azure.net/secrets/Wildcardcontoso"
    }
  }

  apis = {
    "internal" : {
      api_name         = "internal-api"
      revision         = 1
      api_display_name = "Internal Client API"
      path             = "internal"
      protocols        = ["https"]
      service_url      = "http://internal-api.contoso.com"
      subscription     = false
      operations = {
        "info" = {
          operation_name         = "info"
          operation_display_name = "Get Internal Clients Info"
          method                 = "GET"
          url_template           = "/"
          description            = "Get Internal Clients Info."
        }
      }
    }
    "external" : {
      api_name         = "external-api"
      revision         = 1
      api_display_name = "External Client API"
      path             = "external"
      protocols        = ["https"]
      service_url      = "http://external-api.contoso.com"
      subscription     = false
      operations = {
        "info" = {
          operation_name         = "info"
          operation_display_name = "Get External Clients Info"
          method                 = "GET"
          url_template           = "/"
          description            = "Get External Clients Info."
        }
      }
    }
  }
}
```

## Arguments Reference

The following arguments are supported:
  - `application` - (Required) Name of the application for which the virtual network is created (agw,corenet etc.).
  - `environment` - (Required) A 3-digits environment which will be used by resources (hpr,sbx,prd,hyb).
  - `key_vault_id` - (Required) Provide a key vault ID to store information and get certificates. A user-assigned and system-assigned policies will be created.
  - `location` - (Required) The region for which to create the resources.
  - `publisher` - (Required) A `publisher` block as defined below.
  - `resource_group_name` - (Required) Name of the resource group where resources will be created.
  - `subnet_id` - (Required) A subnet ID needed to create the Azure API Management.
  - `technical_zone` - (Required) A 2-digits technical zone which will be used by resources (in,ex,cm,sh).

##
  - `apim_custom_domains` - (Optional) A `apim_custom_domains` map as defined below.
  - `apis` - (Optional) A `apis` map as defined below.
  - `sku_capacity` - (Optional) sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: `Consumption`, `Developer`, `Basic`, `Standard` and `Premium`. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1). Default to `1`.
  - `sku_name` - (Optional) sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: `Consumption`, `Developer`, `Basic`, `Standard` and `Premium`. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1). Default to `Developer`.
  - `tags` - (Optional) A key-value map of string.
  - `virtual_network_type` - (Optional) The type of virtual network you want to use, valid values include: `None`, `External`, `Internal`. Default to `None`.

##
A `apim_custom_domains` map support the following:
  - `domain_key` - (Required) The custom domain type, valid values include: `developer_portal`, `management`, `portal`, `gateway`, `scm`.
  - `hostname` - (Required) The Hostname to use for the corresponding endpoint.
  - `key_vault_id` - (Optional) The ID of the Key Vault Secret containing the SSL Certificate, which must be should be of the type application/x-pkcs12.

##
A `apis` map support the following:
  - `api_display_name` - (Required) The display name of the API.
  - `api_name` - (Required) The name of the API Management API. Changing this forces a new resource to be created.
  - `operations` - (Optional) A map of `operations` as defined below.
  - `path` - (Required) The Path for this API Management API, which is a relative URL which uniquely identifies this API and all of its resource paths within the API Management Service.
  - `protocols` - (Required) A list of protocols the operations in this API can be invoked. Possible values are `http`, `https`, `ws`, and `wss`.
  - `revision` - (Required) The Revision which used for this API.
  - `service_url` - (Required) Absolute URL of the backend service implementing this API.
  - `subscription` - (Required) Should this API require a subscription key?

##
A `operations` map support the following:
  - `description` - (Required) A description for this API Operation, which may include HTML formatting tags.
  - `method` - (Required) The HTTP Method used for this API Management Operation, like `GET`, `DELETE`, `PUT` or `POST` - but not limited to these values.
  - `operation_name` - (Required) A unique identifier for this API Operation. Changing this forces a new resource to be created.
  - `operation_display_name` - (Required) The Display Name for this API Management Operation.
  - `url_template` - (Required) The relative URL Template identifying the target resource for this operation, which may include parameters.


##
A `publisher` object support the following:
  - `email` - (Required) A Email or Distribution List Email as the publisher.
  - `name` - (Required) A name for this Publisher.



## Attribute Reference

The following Attributes are exported:
  - `id` - The ID of the Bastion Host.
  - `dns_name` - The FQDN for the Bastion Host..

## References
Please check the following references for best practices.
* [Terraform Best Practices](https://www.terraform-best-practices.com/)
* [Azure Policy as Code with Terraform Part 1](https://purple.telstra.com/blog/azure-policy-as-code-with-terraform-part-1)