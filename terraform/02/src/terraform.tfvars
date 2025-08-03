cloud_id                = "b1gn1dorn70t254b61dk"
folder_id               = "b1g37fp3h2bmj9dcj58t"
vms_ssh_public_root_key = "~/.ssh/ssh-key-asus-laptop.pub"
vms_ssh_root_key        = "~/.ssh/ssh-key-asus-laptop"

vms_resources = {
  web = {
    cores         = 2
    memory        = 2
    core_fraction = 5
  },
  db = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

metadata = {
  serial-port-enable = 1
  ssh-keys           = "ubuntu:~/.ssh/ssh-key-asus-laptop"
}
