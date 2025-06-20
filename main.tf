terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.139.0"
}

# Определяем провайдер Yandex Cloud
provider "yandex" {
  token     = var.yc_token     # Токен авторизации
  cloud_id  = var.yc_cloud_id  # ID облака
  folder_id = var.yc_folder_id # ID каталога
  zone      = var.yc_zone      # Зона размещения
}

# Создаем сеть
resource "yandex_vpc_network" "default" {
  name = "network"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "default" {
  name           = "subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

# Создаем 3 ВМ
resource "yandex_compute_instance" "vm" {
  count = 3  # количество экземпляров

  name = "vm-${count.index + 1}"  # Имя ВМ: vm-1, vm-2, vm-3

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80j21lmqard15ciskf" # Ubuntu 22.04
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.default.id
    ip_address = "10.0.0.${10 + count.index}" # IP: 10.0.0.10, 10.0.0.11, 10.0.0.12
    nat        = true  # Чтобы можно было выходить в интернет
  }

  metadata = {
    ssh-keys = "rinn:${file("~/.ssh/id_ecdsa.pub")}" # Добавляем SSH-ключ
  }
}