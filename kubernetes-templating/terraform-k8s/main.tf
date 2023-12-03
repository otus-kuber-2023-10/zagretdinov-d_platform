terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  #version                  = 0.35
  #service_account_key_file = key.json
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

data "yandex_compute_image" "ubuntu-image" {
  family = "ubuntu-2004-lts"
}


resource "yandex_compute_instance" "node" {
  name  = "node-${count.index}"
  count = 2

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      #image_id = var.image_id
      image_id = data.yandex_compute_image.ubuntu-image.image_id
      size     = 20
      type     = "network-ssd"
    }
  }

 network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

locals {
  names = yandex_compute_instance.node.*.name
  ips   = yandex_compute_instance.node.*.network_interface.0.nat_ip_address
}

# Invetrory for ansible and run playbook
resource "local_file" "inventory" {
  content = templatefile("inventory.tpl",
    {
      names = local.names,
      addrs = local.ips,
    }
  )
  filename = "../ansible/inventory.ini"
  provisioner "local-exec" {
    command     = "sleep 100 && ansible-playbook node_playbook.yml"
    working_dir = "../ansible"
  }
}
