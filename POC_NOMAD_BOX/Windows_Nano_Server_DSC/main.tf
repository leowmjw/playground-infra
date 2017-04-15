# Main Terraform

# Remote state form ...

terraform {
  required_version = "> 0.9.0"
}

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_client_id}"
  client_secret = "${var.azure_client_secret}"
  tenant_id = "${var.azure_tenant_id}"
}

data "terraform_remote_state" "nomadbox" {
  backend = "local"

  config {
    path = "/Users/leow/Desktop/PROJECTS/DEVOPS/nomad-box/terraform/env-development/terraform.tfstate"
  }
}

resource "azurerm_availability_set" "windows_aset" {
  count = 1
  name = "acme-nomad-dev-windows-aset"
  location = "${data.terraform_remote_state.nomadbox.resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.nomadbox.resource_group_name}"
}
