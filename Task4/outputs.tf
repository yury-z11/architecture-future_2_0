# ─── Network ──────────────────────────────────────────
output "network_id" {
  description = "VPC network ID"
  value       = yandex_vpc_network.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = yandex_vpc_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = yandex_vpc_subnet.private.id
}

# ─── API Gateway VM ──────────────────────────────────
output "api_gateway_public_ip" {
  description = "Public IP of API Gateway VM (entry point)"
  value       = yandex_compute_instance.api_gateway.network_interface[0].nat_ip_address
}

output "api_gateway_internal_ip" {
  description = "Internal IP of API Gateway VM"
  value       = yandex_compute_instance.api_gateway.network_interface[0].ip_address
}

# ─── Data Platform VM ────────────────────────────────
output "data_platform_internal_ip" {
  description = "Internal IP of Data Platform VM (Spark master)"
  value       = yandex_compute_instance.data_platform.network_interface[0].ip_address
}

output "data_storage_disk_id" {
  description = "ID of the additional data storage disk (Delta Lake)"
  value       = yandex_compute_disk.data_storage.id
}

# ─── Kafka ────────────────────────────────────────────
output "kafka_internal_ip" {
  description = "Internal IP of Kafka Broker VM"
  value       = yandex_compute_instance.kafka_broker.network_interface[0].ip_address
}

# ─── PostgreSQL ──────────────────────────────────────
output "postgres_host" {
  description = "PostgreSQL cluster FQDN (internal)"
  value       = yandex_mdb_postgresql_cluster.app_db.host[0].fqdn
}

output "postgres_clinic_db" {
  description = "Clinic database name"
  value       = yandex_mdb_postgresql_database.clinic_db.name
}

output "postgres_fintech_db" {
  description = "Fintech database name"
  value       = yandex_mdb_postgresql_database.fintech_db.name
}

# ─── Connection summary ──────────────────────────────
output "connection_summary" {
  description = "Quick connection reference"
  value = {
    api_gateway_ssh  = "ssh ubuntu@${yandex_compute_instance.api_gateway.network_interface[0].nat_ip_address}"
    kafka_bootstrap  = "${yandex_compute_instance.kafka_broker.network_interface[0].ip_address}:9092"
    postgres_conn    = "postgresql://${var.db_user}@${yandex_mdb_postgresql_cluster.app_db.host[0].fqdn}:5432"
  }
}
