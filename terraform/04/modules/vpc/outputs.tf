output "subnet" {
  description = "Information about the subnet"
  value       = yandex_vpc_subnet.this
}

output "network_id" {
  description = "ID of the VPC network"
  value       = yandex_vpc_network.this.id
}
