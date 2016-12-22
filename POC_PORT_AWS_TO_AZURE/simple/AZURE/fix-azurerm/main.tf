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

provider "fixazurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_access_key}"
  client_secret = "${var.azure_secret_key}"
  tenant_id = "${var.azure_tenant_id}"
}

# Create a resource group
resource "fixazurerm_resource_group" "development" {
  name = "development"
  location = "${var.azure_region}"
  tags {
    environment = "Development"
  }
}

# Main VPC that will contain everything.
resource "fixazurerm_virtual_network" "network" {
  name = "developmentNetwork"
  address_space = [
    "10.0.0.0/16"
  ]
  location = "${var.azure_region}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"

  tags {
    Name = "otto"
  }
}

# The public subnet is where resources connected to the internet will go
resource "fixazurerm_subnet" "subnet1" {
  name = "subnet1"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  virtual_network_name = "${fixazurerm_virtual_network.network.name}"
  address_prefix = "10.0.1.0/24"
}

# Internal network for consul and Nomad
resource "fixazurerm_subnet" "subnet2" {
  name = "subnet2"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  virtual_network_name = "${fixazurerm_virtual_network.network.name}"
  address_prefix = "10.0.2.0/24"
}

# Internal network for consul and Nomad
resource "fixazurerm_subnet" "subnet3" {
  name = "subnet3"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  virtual_network_name = "${fixazurerm_virtual_network.network.name}"
  address_prefix = "10.0.3.0/24"
}

# Availability set; distribute nodes throughout AZ

resource "fixazurerm_availability_set" "development" {
  name = "devavailabilityset"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${fixazurerm_resource_group.development.location}"

  tags {
    environment = "Development"
  }
}

# Route table ....
/*
resource "fixazurerm_route_table" "public" {
  name = "PublicRouteTable"
  location = "${var.azure_region}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"

  tags = {
    environment = "Development"
  }
}

# Internet accessible route table + gateway for the public subnet
resource "fixazurerm_route" "public" {
  name = "InternetRoute"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  address_prefix = "0.0.0.0/0"
  next_hop_type = "Internet"
  route_table_name = "${fixazurerm_route_table.public.name}"
}
*/

# Public IP address?
resource "fixazurerm_public_ip" "pubip" {
  name = "developmentPublicIP"
  location = "${var.azure_region}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "mydev"
}

resource "fixazurerm_public_ip" "pubip2" {
  name = "devPublicIP2"
  location = "${fixazurerm_resource_group.development.location}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "mydev2"

  tags {
    type = "Backup"
  }
}

resource "fixazurerm_public_ip" "pubip3" {
  name = "devPublicIP3"
  location = "${fixazurerm_resource_group.development.location}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "myconsul"

  tags {
    type = "Consul"
  }
}

# Attach LB Public IP address to both the VMs
resource "fixazurerm_public_ip" "lbpip" {
  name = "loadBalancerPublicIP"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${fixazurerm_resource_group.development.location}"
  public_ip_address_allocation = "static"
  domain_name_label = "mydevlb"

  tags {
    environment = "Production"
  }
}

# Load Balancer rules here ..
resource "fixazurerm_lb" "prodlb" {
  name = "TestLoadBalancer"
  location = "${fixazurerm_resource_group.development.location}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = "${fixazurerm_public_ip.lbpip.id}"
  }
}

resource "fixazurerm_lb_probe" "caddy" {
  name = "CaddyTCPProbe"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${fixazurerm_resource_group.development.location}"
  loadbalancer_id = "${fixazurerm_lb.prodlb.id}"
  protocol = "Tcp"
  port = 8080
  interval_in_seconds = 8
  number_of_probes = 4
}

resource "fixazurerm_lb_backend_address_pool" "prodlbpool" {
  name = "BackEndAddressPool"
  location = "${fixazurerm_resource_group.development.location}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  loadbalancer_id = "${fixazurerm_lb.prodlb.id}"
}

resource "fixazurerm_lb_rule" "prodlbrule" {
  name = "LBRule"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${fixazurerm_resource_group.development.location}"
  loadbalancer_id = "${fixazurerm_lb.prodlb.id}"
  frontend_ip_configuration_name = "PublicIPAddress"
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 8080
  backend_address_pool_id = "${fixazurerm_lb_backend_address_pool.prodlbpool.id}"
  probe_id = "${fixazurerm_lb_probe.caddy.id}"
}

# Attach the Public IP address to a Network Interface inside Subnet1 (10.0.1.0/24)
resource "fixazurerm_network_interface" "network_interface" {
  name = "developmentNetworkInterface"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${var.azure_region}"

  ip_configuration {
    name = "ipconfig1"
    public_ip_address_id = "${fixazurerm_public_ip.pubip.id}"
    private_ip_address = "10.0.1.4"
    private_ip_address_allocation = "static"
    subnet_id = "${fixazurerm_subnet.subnet1.id}"
    load_balancer_backend_address_pools_ids = [
      "${fixazurerm_lb_backend_address_pool.prodlbpool.id}"]
  }

  enable_ip_forwarding = true

  tags {
    environment = "Development"
  }

}

# Attach the second Public IP address to NetINterface inside Subnet2
resource "fixazurerm_network_interface" "netint2" {
  name = "devNetworkInterface2"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${fixazurerm_resource_group.development.location}"
  ip_configuration {
    name = "ipconfig1"
    public_ip_address_id = "${fixazurerm_public_ip.pubip2.id}"
    private_ip_address = "10.0.2.4"
    private_ip_address_allocation = "static"
    subnet_id = "${fixazurerm_subnet.subnet2.id}"
    load_balancer_backend_address_pools_ids = [
      "${fixazurerm_lb_backend_address_pool.prodlbpool.id}"]
  }
  enable_ip_forwarding = true

  tags {
    type = "Backup"
  }
}

# Consul Network here ..
resource "fixazurerm_network_interface" "netint3" {
  name = "devNetworkInterface3"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${fixazurerm_resource_group.development.location}"
  ip_configuration {
    name = "ipconfig3"
    public_ip_address_id = "${fixazurerm_public_ip.pubip3.id}"
    private_ip_address = "10.0.3.4"
    private_ip_address_allocation = "static"
    subnet_id = "${fixazurerm_subnet.subnet3.id}"
  }

  enable_ip_forwarding = true

  tags {
    type = "Consul"
  }
}

resource "fixazurerm_storage_account" "development" {
  name = "fixazurermdevsa"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  location = "${var.azure_region}"
  account_type = "Standard_LRS"

  tags {
    environment = "Development"
  }
}

resource "fixazurerm_storage_container" "development" {
  name = "vhds"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  storage_account_name = "${fixazurerm_storage_account.development.name}"
  container_access_type = "private"
}

resource "fixazurerm_virtual_machine" "dev2" {
  count = 1
  name = "backupvm"
  location = "${fixazurerm_resource_group.development.location}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  network_interface_ids = [
    "${fixazurerm_network_interface.netint2.id}"]
  vm_size = "Standard_A0"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"

  }

  storage_os_disk {
    name = "myosdisk2"
    vhd_uri = "${fixazurerm_storage_account.development.primary_blob_endpoint}${fixazurerm_storage_container.development.name}/myosdisk2.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name = "mydatadisk2"
    create_option = "Empty"
    disk_size_gb = 10
    lun = 2
    vhd_uri = "${fixazurerm_storage_account.development.primary_blob_endpoint}${fixazurerm_storage_container.development.name}/mydatadisk2.vhd"
  }

  os_profile {
    computer_name = "backuphost"
    admin_username = "testadmin"
    admin_password = "passw0rd"
    custom_data = "${base64encode(file("cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file("/Users/leow/.ssh/id_rsa.pub")}"
    }
  }

  availability_set_id = "${fixazurerm_availability_set.development.id}"

  tags {
    type = "Backup"
  }
}

resource "fixazurerm_virtual_machine" "development" {
  count = 1
  name = "acctvm"
  location = "${var.azure_region}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  network_interface_ids = [
    "${fixazurerm_network_interface.network_interface.id}"]
  vm_size = "Standard_A0"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "myosdisk1"
    vhd_uri = "${fixazurerm_storage_account.development.primary_blob_endpoint}${fixazurerm_storage_container.development.name}/myosdisk1.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "myprimary"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file("/Users/leow/.ssh/id_rsa.pub")}"
    }
  }

  availability_set_id = "${fixazurerm_availability_set.development.id}"

  tags {
    environment = "Development"
  }
}


resource "fixazurerm_virtual_machine" "consul" {
  count = 1
  name = "consulvm"
  location = "${var.azure_region}"
  resource_group_name = "${fixazurerm_resource_group.development.name}"
  network_interface_ids = [
    "${fixazurerm_network_interface.netint3.id}"]
  # vm_size = "Standard_A0"
  vm_size = "Standard_F2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "myosdisk1"
    vhd_uri = "${fixazurerm_storage_account.development.primary_blob_endpoint}${fixazurerm_storage_container.development.name}/myosdisk3.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "myconsul"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file("/Users/leow/.ssh/id_rsa.pub")}"
    }
  }

  availability_set_id = "${fixazurerm_availability_set.development.id}"

  tags {
    environment = "Development"
  }
}
