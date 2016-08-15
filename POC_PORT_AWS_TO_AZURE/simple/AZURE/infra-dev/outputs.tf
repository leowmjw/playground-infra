output "region" {
  value = "${azurerm_resource_group.development.location}"
}

output "public_ip_adress" {
  value = "${azurerm_public_ip.pubip.ip_address}"
}

output "public_ip_id" {
  value = "${azurerm_public_ip.pubip.id}"
}

output "public_fqdn" {
  value = "${azurerm_public_ip.pubip.fqdn}"
}
