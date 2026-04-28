output "public_vm_external_ip" {
  description = "Публичный IP для подключения к public-vm"
  value       = yandex_compute_instance.public_vm.network_interface.0.nat_ip_address
}

output "public_vm_internal_ip" {
  description = "Внутренний IP public-vm"
  value       = yandex_compute_instance.public_vm.network_interface.0.ip_address
}

output "private_vm_internal_ip" {
  description = "Внутренний IP private-vm"
  value       = yandex_compute_instance.private_vm.network_interface.0.ip_address
}

output "nat_instance_internal_ip" {
  description = "Внутренний IP NAT-инстанса (192.168.10.254)"
  value       = yandex_compute_instance.nat.network_interface.0.ip_address
}

output "nat_instance_external_ip" {
  description = "Публичный IP NAT-инстанса"
  value       = yandex_compute_instance.nat.network_interface.0.nat_ip_address
}