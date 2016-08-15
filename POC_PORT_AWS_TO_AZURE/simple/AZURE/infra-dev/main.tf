variable "ARM_SUBSCRIPTION_ID"
{
  description = "Needs to match exactly??? why??"
}

variable "azure_access_key" {
  description = "Access key for Azure"
}

variable "azure_secret_key" {
  description = "Secret Key for Azure"
}

variable "azure_subscription_id" {
  description = "Subscription ID; get from Console .."
}

variable "azure_tenant_id" {
  description = "Tenant ID; from EndPoint in classic panel .."
}

variable "azure_region" {
  description = "Region where we will operate; default to SG"
  default = "Southeast Asia"
}

provider "azurerm" {
  subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
  client_id = "${var.azure_access_key}"
  client_secret = "${var.azure_secret_key}"
  tenant_id = "${var.azure_tenant_id}"
  alias = "sinar_proj"
}

# Create a resource group

resource "azurerm_resource_group" "development" {
  name = "development"
  location = "${var.azure_region}"
  tags {
    environment = "Development"
  }
}

# Public IP address?

resource "azurerm_public_ip" "pubip" {
  name = "developmentPublicIP"
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  public_ip_address_allocation = "static"
  domain_name_label = "mydevelopment"
}

# Create a virtual network in the web_servers resource group

resource "azurerm_virtual_network" "network" {
  name = "developmentNetwork"
  address_space = [
    "10.0.0.0/16"
  ]
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"

  subnet {
    name = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name = "subnet3"
    address_prefix = "10.0.3.0/24"
  }
}

resource "azurerm_subnet" "subnet" {
  name = "subnet1"
  resource_group_name = "${azurerm_resource_group.development.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "10.0.1.0/24"
}

resource "azurerm_network_interface" "network_interface" {
  name = "developmentNetworkInterface"
  resource_group_name = "${azurerm_resource_group.development.name}"
  location = "${var.azure_region}"

  ip_configuration {
    name = "ipconfig1"
    public_ip_address_id = "${azurerm_public_ip.pubip.id}"
    private_ip_address_allocation = "dynamic"
    subnet_id = "${azurerm_subnet.subnet.id}"
  }

  tags {
    environment = "Development"
  }
}
