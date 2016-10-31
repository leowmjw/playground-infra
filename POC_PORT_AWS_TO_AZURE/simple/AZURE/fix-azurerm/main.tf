variable "ARM_SUBSCRIPTION_ID"
{
  description = "Subscription ID for the Azure Trial; FREE CREDITS!!"
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

variable "access_key" {
  default = "DUUDE.."
}

provider "fixazurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_access_key}"
  client_secret = "${var.azure_secret_key}"
  tenant_id = "${var.azure_tenant_id}"
}


resource "fixazurerm_instance" "bob" {

  name = "bob"
  location = "bob"
  resource_group_name = "bob"
  vm_size = "1"
  storage_os_disk = {}
  os_profile = {}
  network_interface_ids = {}

}

/*
provider "azurerm" {
  # subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
  subscription_id = "abcdef"
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

# Main VPC that will contain everything.
resource "azurerm_virtual_network" "network" {
  name = "developmentNetwork"
  address_space = [
    "10.0.0.0/16"
  ]
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"

  tags {
    Name = "otto"
  }
}

# The public subnet is where resources connected to the internet will go
resource "azurerm_subnet" "subnet1" {
  name = "subnet1"
  resource_group_name = "${azurerm_resource_group.development.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "10.0.1.0/24"
}

# Internal network for consul and Nomad
resource "azurerm_subnet" "subnet2" {
  name = "subnet2"
  resource_group_name = "${azurerm_resource_group.development.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "10.0.2.0/24"
}

# Internal network for consul and Nomad
resource "azurerm_subnet" "subnet3" {
  name = "subnet3"
  resource_group_name = "${azurerm_resource_group.development.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "10.0.3.0/24"
}

# Route table ....
resource "azurerm_route_table" "public" {
  name = "PublicRouteTable"
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"

  tags = {
    environment = "Development"
  }
}

# Internet accessible route table + gateway for the public subnet
resource "azurerm_route" "public" {
  name = "InternetRoute"
  resource_group_name = "${azurerm_resource_group.development.name}"
  address_prefix = "0.0.0.0/0"
  next_hop_type = "Internet"
  route_table_name = "${azurerm_route_table.public.name}"
}

*/

// SKU for Storage is as below
/*

  "sku": {
    "name": "Standard_LRS",
    "tier": "Standard"
  }
  "sku": {
    "name": "Premium_LRS",
    "tier": "Premium"
  }
*/

# Public IP address?
/*
resource "azurerm_public_ip" "pubip" {
  name = "developmentPublicIP"
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  public_ip_address_allocation = "static"
  domain_name_label = "mydevelopment"
}



resource "azurerm_network_interface" "network_interface" {
  name = "developmentNetworkInterface"
  resource_group_name = "${azurerm_resource_group.development.name}"
  location = "${var.azure_region}"

  ip_configuration {
    name = "ipconfig1"
    public_ip_address_id = "${azurerm_public_ip.pubip.id}"
    private_ip_address_allocation = "dynamic"
    subnet_id = "${azurerm_subnet.subnet1.id}"
  }

  tags {
    environment = "Development"
  }

}

*/


