# ─── Yandex Cloud credentials ───────────────────────
variable "yc_token" {
  description = "Yandex Cloud OAuth token (YC_TOKEN env var)"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

# ─── Project ──────────────────────────────────────────
variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "future20"
}

variable "ubuntu_image_id" {
  description = "Ubuntu 22.04 LTS image ID in Yandex Cloud"
  type        = string
  default     = "fd8smb7fj0oq9tq60kic" # ubuntu-22-04-lts-v20240429
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "admin_cidr" {
  description = "Admin IP CIDR for SSH access (e.g. your public IP)"
  type        = string
  default     = "0.0.0.0/0"
}

# ─── API Gateway VM ──────────────────────────────────
variable "api_gw_cores" {
  description = "vCPU cores for API Gateway VM"
  type        = number
  default     = 2
}

variable "api_gw_memory_gb" {
  description = "RAM (GB) for API Gateway VM"
  type        = number
  default     = 4
}

variable "api_gw_disk_gb" {
  description = "Boot disk size (GB) for API Gateway VM"
  type        = number
  default     = 30
}

# ─── Data Platform VM ────────────────────────────────
variable "data_cores" {
  description = "vCPU cores for Data Platform VM (Spark)"
  type        = number
  default     = 8
}

variable "data_memory_gb" {
  description = "RAM (GB) for Data Platform VM"
  type        = number
  default     = 32
}

variable "data_disk_gb" {
  description = "Boot disk size (GB) for Data Platform VM"
  type        = number
  default     = 50
}

variable "data_storage_size_gb" {
  description = "Secondary disk for Delta Lake data storage (GB)"
  type        = number
  default     = 500
}

# ─── Kafka VM ────────────────────────────────────────
variable "kafka_cores" {
  description = "vCPU cores for Kafka Broker VM"
  type        = number
  default     = 4
}

variable "kafka_memory_gb" {
  description = "RAM (GB) for Kafka Broker VM"
  type        = number
  default     = 8
}

variable "kafka_disk_gb" {
  description = "Boot disk size (GB) for Kafka VM"
  type        = number
  default     = 100
}

# ─── PostgreSQL ──────────────────────────────────────
variable "pg_preset" {
  description = "PostgreSQL resource preset ID"
  type        = string
  default     = "s2.medium" # 4 vCPU, 16 GB RAM
}

variable "pg_disk_gb" {
  description = "PostgreSQL cluster disk size (GB)"
  type        = number
  default     = 50
}

variable "db_user" {
  description = "PostgreSQL application user"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "PostgreSQL application user password"
  type        = string
  sensitive   = true
}
