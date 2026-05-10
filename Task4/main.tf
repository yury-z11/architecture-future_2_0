terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# ─────────────────────────────────────────────
# NETWORK
# ─────────────────────────────────────────────

resource "yandex_vpc_network" "main" {
  name = "${var.project_name}-network"
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.project_name}-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route" {
  name       = "${var.project_name}-nat-route"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.project_name}-public"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "${var.project_name}-private"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

# ─────────────────────────────────────────────
# SECURITY GROUPS
# ─────────────────────────────────────────────

resource "yandex_vpc_security_group" "api_sg" {
  name       = "${var.project_name}-api-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTPS"
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP"
  }

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
    description    = "SSH admin"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All outbound"
  }
}

resource "yandex_vpc_security_group" "internal_sg" {
  name       = "${var.project_name}-internal-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group"
    description       = "Internal communication"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All outbound"
  }
}

# ─────────────────────────────────────────────
# COMPUTE: API GATEWAY VM
# ─────────────────────────────────────────────

resource "yandex_compute_instance" "api_gateway" {
  name        = "${var.project_name}-api-gateway"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = var.api_gw_cores
    memory        = var.api_gw_memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.api_gw_disk_gb
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.api_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  labels = {
    role    = "api-gateway"
    project = var.project_name
  }
}

# ─────────────────────────────────────────────
# COMPUTE: DATA PLATFORM VM (Spark master)
# ─────────────────────────────────────────────

resource "yandex_compute_instance" "data_platform" {
  name        = "${var.project_name}-data-platform"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = var.data_cores
    memory        = var.data_memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.data_disk_gb
      type     = "network-ssd"
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data_storage.id
    mode    = "READ_WRITE"
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  labels = {
    role    = "data-platform"
    project = var.project_name
  }
}

# ─────────────────────────────────────────────
# COMPUTE: KAFKA BROKER VM
# ─────────────────────────────────────────────

resource "yandex_compute_instance" "kafka_broker" {
  name        = "${var.project_name}-kafka"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = var.kafka_cores
    memory        = var.kafka_memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.kafka_disk_gb
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  labels = {
    role    = "kafka-broker"
    project = var.project_name
  }
}

# ─────────────────────────────────────────────
# DISK: Data Storage (Delta Lake / Lakehouse)
# ─────────────────────────────────────────────

resource "yandex_compute_disk" "data_storage" {
  name = "${var.project_name}-data-storage"
  type = "network-hdd"
  zone = var.yc_zone
  size = var.data_storage_size_gb

  labels = {
    role    = "data-storage"
    project = var.project_name
  }
}

# ─────────────────────────────────────────────
# MANAGED POSTGRESQL
# ─────────────────────────────────────────────

resource "yandex_mdb_postgresql_cluster" "app_db" {
  name        = "${var.project_name}-postgres"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.main.id

  config {
    version = "15"
    resources {
      resource_preset_id = var.pg_preset
      disk_type_id       = "network-ssd"
      disk_size          = var.pg_disk_gb
    }
  }

  host {
    zone      = var.yc_zone
    subnet_id = yandex_vpc_subnet.private.id
  }

  security_group_ids = [yandex_vpc_security_group.internal_sg.id]
}

resource "yandex_mdb_postgresql_user" "app_user" {
  cluster_id = yandex_mdb_postgresql_cluster.app_db.id
  name       = var.db_user
  password   = var.db_password
}

resource "yandex_mdb_postgresql_database" "clinic_db" {
  cluster_id = yandex_mdb_postgresql_cluster.app_db.id
  name       = "clinic_db"
  owner      = yandex_mdb_postgresql_user.app_user.name
}

resource "yandex_mdb_postgresql_database" "fintech_db" {
  cluster_id = yandex_mdb_postgresql_cluster.app_db.id
  name       = "fintech_db"
  owner      = yandex_mdb_postgresql_user.app_user.name
}
