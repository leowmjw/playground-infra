# ==========================================================
#
# Description: Nodes to execute Nomad workloads.  Make them
#   beefier; the F-series variants?  Keep it in diff AZ.
#
# ===========================================================

variable "num_node" {
  default = 1
}

variable "disable_subnet1" {
  default = 0
}

variable "disable_subnet2" {
  default = 1
}

variable "enable_subnet3" {
  default = 1
}

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_access_key}"
  client_secret = "${var.azure_secret_key}"
  tenant_id = "${var.azure_tenant_id}"
}

resource azurerm_resource_group "nomadrg" {
  name = "nomad-resources"
  location = "${var.azure_region}"
  tags {
    type = "Development"
  }
}

resource azurerm_availability_set "nomadas" {
  count = 1
  name = "nomad-availset"
  location = "${azurerm_resource_group.nomadrg.location}"
  resource_group_name = "${azurerm_resource_group.nomadrg.name}"
}

# Subnet1
resource "azurerm_network_interface" "nomadnif" {
  count = "${var.num_node - (var.disable_subnet1 * var.num_node)}"
  name = "nomadif-${count.index + 1}"
  location = "${azurerm_resource_group.nomadrg.location}"
  resource_group_name = "${azurerm_resource_group.nomadrg.name}"
  ip_configuration {
    name = "ipconfig-${count.index}"
    private_ip_address_allocation = "dynamic"
    subnet_id = "${fixazurerm_subnet.subnet1.id}"
  }

  enable_ip_forwarding = true
  internal_dns_name_label = "nomad-node-s1-${count.index + 1}"

  tags {
    type = "Network"
  }
}
# Subnet2
resource "azurerm_network_interface" "nomadnifs2" {
  count = "${var.num_node - (var.disable_subnet2 * var.num_node)}"
  name = "nomadif-s2-${count.index + 1}"
  location = "${azurerm_resource_group.nomadrg.location}"
  resource_group_name = "${azurerm_resource_group.nomadrg.name}"
  ip_configuration {
    name = "ipconfig-${count.index}"
    private_ip_address_allocation = "dynamic"
    subnet_id = "${fixazurerm_subnet.subnet2.id}"
  }

  enable_ip_forwarding = true
  internal_dns_name_label = "nomad-node-s2-${count.index + 1}"

  tags {
    type = "Network"
  }
}

# Subnet3
resource "azurerm_network_interface" "nomadnifs3" {
  count = "${var.enable_subnet3 * var.num_node}"
  name = "nomadif-s3-${count.index + 1}"
  location = "${azurerm_resource_group.nomadrg.location}"
  resource_group_name = "${azurerm_resource_group.nomadrg.name}"
  ip_configuration {
    name = "ipconfig-${count.index}"
    private_ip_address_allocation = "dynamic"
    subnet_id = "${fixazurerm_subnet.subnet3.id}"
  }

  enable_ip_forwarding = true
  internal_dns_name_label = "nomad-node-s3-${count.index + 1}"

  tags {
    type = "Network"
  }
}

# Subnet1
resource azurerm_virtual_machine "nomadvm" {
  count = "${var.num_node - (var.disable_subnet1 * var.num_node)}"
  name = "nomad-vm-s1-${count.index + 1}"
  location = "${azurerm_resource_group.nomadrg.location}"
  resource_group_name = "${azurerm_resource_group.nomadrg.name}"

  availability_set_id = "${element(azurerm_availability_set.nomadas.*.id, count.index)}"
  network_interface_ids = ["${element(azurerm_network_interface.nomadnif.*.id, count.index)}"]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  vm_size = "Standard_F4"

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "myosdisk-nomad-vm-s1-${count.index + 1}"
    vhd_uri = "${fixazurerm_storage_account.development.primary_blob_endpoint}${fixazurerm_storage_container.development.name}/nomad-vm-s1-${count.index + 1}.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "nomad-vm-s1-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("node-cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file("/Users/leow/.ssh/id_rsa.pub")}"
    }
  }

  tags {
    type = "Production"
    use = "Nomad"
  }
}

# Subnet2
resource azurerm_virtual_machine "nomadvm2" {
  count = "${var.num_node - (var.disable_subnet2 * var.num_node)}"
  name = "nomad-vm-s2-${count.index + 1}"
  location = "${azurerm_resource_group.nomadrg.location}"
  resource_group_name = "${azurerm_resource_group.nomadrg.name}"

  availability_set_id = "${element(azurerm_availability_set.nomadas.*.id, count.index)}"
  network_interface_ids = ["${element(azurerm_network_interface.nomadnifs2.*.id, count.index)}"]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  vm_size = "Standard_F4"

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "myosdisk-nomad-vm-s2-${count.index + 1}"
    vhd_uri = "${fixazurerm_storage_account.development.primary_blob_endpoint}${fixazurerm_storage_container.development.name}/nomad-vm-s2-${count.index + 1}.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "nomad-vm-s2-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("node-cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file("/Users/leow/.ssh/id_rsa.pub")}"
    }
  }

  tags {
    type = "Production"
    use = "Nomad"
  }
}

# Subnet3
resource azurerm_virtual_machine "nomadvm3" {
  count = "${var.enable_subnet3 * var.num_node}"
  name = "nomad-vm-s3-${count.index + 1}"
  location = "${azurerm_resource_group.nomadrg.location}"
  resource_group_name = "${azurerm_resource_group.nomadrg.name}"

  availability_set_id = "${element(azurerm_availability_set.nomadas.*.id, count.index)}"
  network_interface_ids = ["${element(azurerm_network_interface.nomadnifs3.*.id, count.index)}"]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  vm_size = "Standard_F4"

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "myosdisk-nomad-vm-s3-${count.index + 1}"
    vhd_uri = "${fixazurerm_storage_account.development.primary_blob_endpoint}${fixazurerm_storage_container.development.name}/nomad-vm-s3-${count.index + 1}.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "nomad-vm-s3-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("node-cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file("/Users/leow/.ssh/id_rsa.pub")}"
    }
  }

  tags {
    type = "Production"
    use = "Nomad"
  }
}
