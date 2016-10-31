/*
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

*/


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
