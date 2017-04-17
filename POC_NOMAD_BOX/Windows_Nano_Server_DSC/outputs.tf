output "public_ip_primary" {
  value = "${azurerm_public_ip.pubip.ip_address}"
}

output "public_fqdn_primary" {
  value = "${azurerm_public_ip.pubip.fqdn}"
}

output "public_ip_backup" {
  value = "${azurerm_public_ip.pubip2.ip_address}"
}

output "public_fqdn_backup" {
  value = "${azurerm_public_ip.pubip2.fqdn}"
}

output "public_ip_windows" {
  value = "${azurerm_public_ip.pubip3.ip_address}"
}

output "public_fqdn_windows" {
  value = "${azurerm_public_ip.pubip3.fqdn}"
}
