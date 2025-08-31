locals {
  web_instances_simple = [
    for vm in yandex_compute_instance.web :
    {
      name           = vm.name
      fqdn           = vm.fqdn
      nat_ip_address = vm.network_interface[0].nat_ip_address
    }
  ]

  db_instances_simple = [
    for vm in yandex_compute_instance.db :
    {
      name           = vm.name
      fqdn           = vm.fqdn
      nat_ip_address = vm.network_interface[0].nat_ip_address
    }
  ]

  storage_instance_simple = {
    name           = yandex_compute_instance.storage.name
    fqdn           = yandex_compute_instance.storage.fqdn
    nat_ip_address = yandex_compute_instance.storage.network_interface[0].nat_ip_address
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  content  = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.web_instances_simple
    dbs        = local.db_instances_simple
    storage    = local.storage_instance_simple
  })
}
