output "vm_ips" {
  value = yandex_compute_instance.vm[*].network_interface.0.ip_address
}