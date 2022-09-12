##########################################################################
# 0. Global Configuration
##########################################################################
variable "application" {
  description = "Name of the application for which the resources are created (agw,corenet etc.)"
  type        = string
}

variable "technical_zone" {
  description = "Enter a 2-digits technical zone which will be used by resources (in,ex,cm,sh)"
  type        = string

  validation {
    condition = (
      length(var.technical_zone) > 0 && length(var.technical_zone) <= 2
    )
    error_message = "The technical zone must be a 2-digits string."
  }
}
variable "environment" {
  description = "Enter the 3-digits environment which will be used by resources (hpr,sbx,prd,hyb)"
  type        = string

  validation {
    condition = (
      length(var.environment) > 0 && length(var.environment) <= 3
    )
    error_message = "The environment must be a 3-digits string."
  }
}

variable "location" {
  description = "Enter the region for which to create the resources."
}

variable "tags" {
  description = "Tags to apply to your resources"
  type        = map(string)
  default = {}
}

variable "resource_group_name" {
  description = "Name of the resource group where resources will be created"
  type        = string
}

##########################################################################
# 1. Virtual Network Configuration
##########################################################################

variable "subnet_id" {
  description = "A subnet ID needed to create the virtual machine"
  type        = string
}

variable "key_vault_id" {
  description = "Provide a key vault ID to store information and get certificates. A user-assigned and system-assigned policies will be created."
  type        = string
}

##########################################################################
# 2. API Management
##########################################################################

variable "publisher" {
  description = "Publisher Information for API Management"
  type = object({
    name  = string
    email = string
  })
}

variable "sku_name" {
  description = "sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)."
  type        = string
  default     = "Developer"
  validation {
    condition = (
      var.sku_name == "Developer" || var.sku_name == "Consumption" || var.sku_name == "Basic" || var.sku_name == "Standard" || var.sku_name == "Premium"
    )
    error_message = "The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium."
  }
}

variable "sku_capacity" {
  description = "(Required) sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)."
  type        = number
  default     = 1
  validation {
    condition = (
      var.sku_capacity >= 1 && var.sku_capacity < 13
    )
    error_message = "The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)."
  }
}

variable "virtual_network_type" {
  description = "(Optional) The type of virtual network you want to use, valid values include: None, External, Internal"
  type        = string
  default     = "None"
  validation {
    condition = (
      var.virtual_network_type == "None" || var.virtual_network_type == "External" || var.virtual_network_type == "Internal"
    )
    error_message = "Valid values include: None, External, Internal."
  }
}

variable "apim_custom_domains" {
  description = "Map of custom domains"
  type = map(object({
    domain_key   = string
    host_name    = string
    key_vault_id = string
  }))
  default = {}
}

variable "apis" {
  description = "APIs and Operation maps"
  type = map(object({
    api_name         = string
    revision         = number
    api_display_name = string
    path             = string
    protocols        = list(string)
    service_url      = string
    subscription     = bool
    operations = map(object({
      operation_name         = string
      operation_display_name = string
      method                 = string
      url_template           = string
      description            = string
    }))
  }))

  default = {}
}