output "region" {
  value = "${fixazurerm_resource_group.development.location}"
}

output "public_ip_adress" {
  value = "${fixazurerm_public_ip.lbpip.ip_address}"
}

output "public_fqdn" {
  value = "${fixazurerm_public_ip.lbpip.fqdn}"
}

output "public_ip_primary" {
  value = "${fixazurerm_public_ip.pubip.ip_address}"
}

output "public_fqdn_primary" {
  value = "${fixazurerm_public_ip.pubip.fqdn}"
}

output "public_ip_backup" {
  value = "${fixazurerm_public_ip.pubip2.ip_address}"
}

output "public_fqdn_backup" {
  value = "${fixazurerm_public_ip.pubip2.fqdn}"
}

output "public_ip_consul" {
  value = "${fixazurerm_public_ip.pubip3.ip_address}"
}

output "public_fqdn_consul" {
  value = "${fixazurerm_public_ip.pubip3.fqdn}"
}

/*
 **** TO BE PORTED ******

output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "vpc_cidr" {
    value = "${aws_vpc.main.cidr_block}"
}

output "subnet_public" {
    value = "${aws_subnet.public.id}"
}

output "key_name" {
    value = "${aws_key_pair.main.id}"
}

output "infra_id" {
    value = "${element(split("-", aws_vpc.main.id), 1)}"
}

*/
