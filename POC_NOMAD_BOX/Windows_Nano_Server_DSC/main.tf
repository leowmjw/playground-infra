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
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_access_key}"
  client_secret = "${var.azure_secret_key}"
  tenant_id = "${var.azure_tenant_id}"
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

# Availability set; distribute nodes throughout AZ

resource "azurerm_availability_set" "development" {
  name = "devavailabilityset"
  resource_group_name = "${azurerm_resource_group.development.name}"
  location = "${azurerm_resource_group.development.location}"

  tags {
    environment = "Development"
  }
}

# Public IP address?
resource "azurerm_public_ip" "pubip" {
    count = 1
  name = "developmentPublicIP"
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "mydev"
}

resource "azurerm_public_ip" "pubip2" {
    count = 0
  name = "devPublicIP2"
  location = "${azurerm_resource_group.development.location}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "mydev2"

  tags {
    type = "Backup"
  }
}

resource "azurerm_public_ip" "pubip3" {
    count = 1
  name = "devPublicIP3"
  location = "${azurerm_resource_group.development.location}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "myconsul"

  tags {
    type = "Consul"
  }
}

# Attach the Public IP address to a Network Interface inside Subnet1 (10.0.1.0/24)
resource "azurerm_network_interface" "network_interface" {
    count = 1
  name = "developmentNetworkInterface"
  resource_group_name = "${azurerm_resource_group.development.name}"
  location = "${var.azure_region}"

  ip_configuration {
    name = "ipconfig1"
    public_ip_address_id = "${azurerm_public_ip.pubip.id}"
    private_ip_address = "10.0.1.4"
    private_ip_address_allocation = "static"
        subnet_id = "${azurerm_subnet.subnet1.id}"
  }

  enable_ip_forwarding = true

  tags {
    environment = "Development"
  }

}

# Attach the second Public IP address to NetINterface inside Subnet2
resource "azurerm_network_interface" "netint2" {
    count = 0
  name = "devNetworkInterface2"
  resource_group_name = "${azurerm_resource_group.development.name}"
  location = "${azurerm_resource_group.development.location}"
  ip_configuration {
    name = "ipconfig1"
    public_ip_address_id = "${azurerm_public_ip.pubip2.id}"
    private_ip_address = "10.0.2.4"
    private_ip_address_allocation = "static"
    subnet_id = "${azurerm_subnet.subnet2.id}"
  }
  enable_ip_forwarding = true

  tags {
    type = "Backup"
  }
}

# Consul Network here ..
resource "azurerm_network_interface" "netint3" {
    count = 1
  name = "devNetworkInterface3"
  resource_group_name = "${azurerm_resource_group.development.name}"
  location = "${azurerm_resource_group.development.location}"
  ip_configuration {
    name = "ipconfig3"
    public_ip_address_id = "${azurerm_public_ip.pubip3.id}"
    private_ip_address = "10.0.3.4"
    private_ip_address_allocation = "static"
    subnet_id = "${azurerm_subnet.subnet3.id}"
  }

  enable_ip_forwarding = true

  tags {
    type = "Windows"
  }
}

resource "azurerm_storage_account" "development" {
  name = "azurermdevsa"
  resource_group_name = "${azurerm_resource_group.development.name}"
  location = "${var.azure_region}"
  account_type = "Standard_LRS"

  tags {
    environment = "Development"
  }
}

resource "azurerm_storage_container" "development" {
  name = "vhds"
  resource_group_name = "${azurerm_resource_group.development.name}"
  storage_account_name = "${azurerm_storage_account.development.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "dev2" {
  count = 0
  name = "backupvm"
  location = "${azurerm_resource_group.development.location}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  network_interface_ids = [
    "${azurerm_network_interface.netint2.id}"]
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
    vhd_uri = "${azurerm_storage_account.development.primary_blob_endpoint}${azurerm_storage_container.development.name}/myosdisk2.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name = "mydatadisk2"
    create_option = "Empty"
    disk_size_gb = 10
    lun = 2
    vhd_uri = "${azurerm_storage_account.development.primary_blob_endpoint}${azurerm_storage_container.development.name}/mydatadisk2.vhd"
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

  availability_set_id = "${azurerm_availability_set.development.id}"

  tags {
    type = "Backup"
  }
}

resource "azurerm_virtual_machine" "development" {
  count = 1
  name = "acctvm"
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  network_interface_ids = [
    "${azurerm_network_interface.network_interface.id}"]
  vm_size = "Standard_D2_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "myosdisk1"
    vhd_uri = "${azurerm_storage_account.development.primary_blob_endpoint}${azurerm_storage_container.development.name}/myosdisk1.vhd"
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

  availability_set_id = "${azurerm_availability_set.development.id}"

  tags {
    environment = "Development"
  }
}


resource "azurerm_virtual_machine" "windows" {
  count = 1
  name = "windowsvm"
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  network_interface_ids = [
    "${azurerm_network_interface.netint3.id}"]
  # vm_size = "Standard_A0"
  vm_size = "Standard_D4_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter-with-Containers"
    version = "latest"
  }

  storage_os_disk {
    name = "myosdisk1"
    vhd_uri = "${azurerm_storage_account.development.primary_blob_endpoint}${azurerm_storage_container.development.name}/myosdisk3.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "myconsul"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("cloud-init.txt"))}"
  }

  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades  = true
    winrm {
      protocol = "http"
    }
  }

  availability_set_id = "${azurerm_availability_set.development.id}"

  tags {
    environment = "Development"
  }
}


resource "null_resource" "winrm" {

    connection {
        type = "winrm"
        user = "testadmin"
        password = "Password1234!"
        insecure = true
        host = "10.0.3.4"
    }

       provisioner "remote-exec" {
        inline = [
          "powershell mkdir /opt",
          "powershell cp /AzureData/* /opt/."
        ]
    }

}