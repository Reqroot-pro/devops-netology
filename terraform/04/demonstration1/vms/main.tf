# Шаблонизация cloud-init
data "template_file" "cloudinit" {
  template = file("${path.module}/cloud-init.yml")
  vars = {
    ssh_key = var.public_key
  }
}

# Модуль VPC
module "vpc_dev" {
  source   = "../../modules/vpc"
  env_name = "develop"
  zone     = "ru-central1-a"
  cidr     = "10.0.1.0/24"
}

# Модуль для проекта marketing
module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=4d05fab828b1fcae16556a4d167134efca2fccf2"
  env_name       = "marketing"
  network_id     = module.vpc_dev.network_id
  subnet_zones   = [module.vpc_dev.subnet.zone]
  subnet_ids     = [module.vpc_dev.subnet.id]
  instance_name  = "marketing-web"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

# Модуль для проекта analytics
module "analytics_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=4d05fab828b1fcae16556a4d167134efca2fccf2"
  env_name       = "analytics"
  network_id     = module.vpc_dev.network_id
  subnet_zones   = [module.vpc_dev.subnet.zone]
  subnet_ids     = [module.vpc_dev.subnet.id]
  instance_name  = "analytics-web"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

# Outputs
output "marketing_fqdn" {
  value = module.marketing_vm.fqdn
}

output "analytics_fqdn" {
  value = module.analytics_vm.fqdn
}

output "all_fqdns" {
  value = concat(module.marketing_vm.fqdn, module.analytics_vm.fqdn)
}
