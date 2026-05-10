# Task 4 — Обоснование конфигурации Terraform

## 1. Архитектура инфраструктуры

### Компоненты, управляемые Terraform (IaC)

| Компонент | Ресурс Terraform | Назначение |
|---|---|---|
| VPC Network | `yandex_vpc_network` | Изолированная сеть проекта |
| Public subnet | `yandex_vpc_subnet.public` | Размещение публично доступных VM |
| Private subnet | `yandex_vpc_subnet.private` | Изолированные внутренние сервисы |
| NAT Gateway | `yandex_vpc_gateway` + `yandex_vpc_route_table` | Исходящий интернет для private-подсети |
| Security Groups | `yandex_vpc_security_group` | Firewall-правила для API и внутренних сервисов |
| API Gateway VM | `yandex_compute_instance.api_gateway` | 2 CPU / 4 GB RAM / SSD 30 GB / публичный IP |
| Data Platform VM | `yandex_compute_instance.data_platform` | 8 CPU / 32 GB RAM / SSD 50 GB + HDD 500 GB |
| Kafka Broker VM | `yandex_compute_instance.kafka_broker` | 4 CPU / 8 GB RAM / SSD 100 GB |
| Data Storage Disk | `yandex_compute_disk.data_storage` | HDD 500 GB для Delta Lake (Data Lakehouse) |
| PostgreSQL cluster | `yandex_mdb_postgresql_cluster` | Managed PostgreSQL 15, s2.medium |
| clinic_db | `yandex_mdb_postgresql_database` | БД для домена «Клиники» |
| fintech_db | `yandex_mdb_postgresql_database` | БД для домена «Финтех» |

### Компоненты, разворачиваемые вручную (после terraform apply)

| Компонент | Причина ручного развёртывания |
|---|---|
| Apache Kafka (установка на VM) | Требует настройки ZooKeeper/KRaft, топиков, ACL |
| Apache Spark (установка на VM) | Требует конфигурации workers, настройки Spark Submit |
| Kong API Gateway (установка на VM) | Требует создания routes, plugins, consumers |
| SSL-сертификаты | Let's Encrypt — должны генерироваться с реального домена |
| Kafka Connect коннекторы | Настройка источников/приёмников под конкретные топики |
| dbt проект | Разработка трансформаций под конкретную схему данных |

---

## 2. Обоснование размеров ресурсов

### API Gateway VM: 2 vCPU / 4 GB RAM / 30 GB SSD

Kong API Gateway — stateless-прокси. Основная нагрузка — маршрутизация HTTP-запросов. 2 CPU обеспечивают ~10,000 RPS. 4 GB RAM достаточно для Kong и его плагинов. SSD выбран для быстрой обработки запросов.

### Data Platform VM: 8 vCPU / 32 GB RAM / 50 GB SSD + 500 GB HDD

Apache Spark требует значительной памяти для in-memory обработки. 32 GB позволяют запускать задачи на данных до ~100 GB. SSD-диск для ОС и Spark executors (быстрый I/O). HDD 500 GB — экономичное хранение Delta Lake (данные не требуют низкой latency, важен объём).

### Kafka VM: 4 vCPU / 8 GB RAM / 100 GB SSD

Kafka активно использует page cache ОС. 8 GB RAM обеспечивает кеширование горячих данных. SSD выбран для минимального latency при записи/чтении логов. 100 GB покрывает хранение событий за 7 дней с retention policy.

### PostgreSQL: s2.medium (4 vCPU / 16 GB RAM) / 50 GB SSD

Managed PostgreSQL для оперативных БД клиник и финтех. s2.medium — баланс производительности и стоимости для OLTP-нагрузки. 50 GB SSD покрывает текущие оперативные данные (не исторические — они в Lakehouse).

### NAT Gateway

Private-подсеть не имеет публичных IP на VM — это снижает поверхность атаки. NAT Gateway обеспечивает исходящий интернет для установки пакетов и обновлений без открытия VM для входящих соединений.

---

## 3. Разделение на public / private подсети

- **Public (10.0.1.0/24):** только API Gateway с публичным IP. Единственная точка входа из интернета.
- **Private (10.0.2.0/24):** Data Platform, Kafka, PostgreSQL. Не доступны из интернета напрямую. Доступ только через API Gateway или SSH-туннель.

Это обеспечивает принцип defense-in-depth: компрометация внешнего сервиса не даёт прямого доступа к данным.

---

## 4. Почему декларативный подход (IaC / Terraform)

### Воспроизводимость
Конфигурация в коде гарантирует идентичное окружение при каждом запуске. Устраняет проблему "works on my machine". Можно развернуть точную копию prod-среды для staging и тестирования.

### Масштабируемость
Добавление нового домена (например, фармацевтика) = добавление новых ресурсов в `main.tf`. Нет ручных кликов в консоли, нет риска пропустить шаг.

### Версионный контроль
Terraform-конфигурация хранится в Git. Любое изменение инфраструктуры — это PR с code review. История изменений видна в git log. Можно откатить инфраструктуру к любому прошлому состоянию.

### State management
`terraform plan` показывает точно, что изменится, до применения. `terraform.tfstate` позволяет Terraform знать текущее состояние и вносить только необходимые изменения.

### Командная работа
Один разработчик описывает инфраструктуру, другие могут её воспроизвести командой `terraform apply`. DevOps не является узким местом.

---

## 5. Команды для тестирования (WSL 2.0 Ubuntu)

```bash
# Установка Terraform в WSL2 Ubuntu
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# Установка Yandex Cloud CLI (опционально)
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

# Работа с Terraform
cd Task4/
terraform init      # инициализация провайдеров
terraform validate  # проверка синтаксиса
terraform plan      # предпросмотр изменений
terraform apply     # применение (требует подтверждения)

# Проверка созданных ресурсов
terraform output    # вывод ключевых параметров

# Уничтожение тестовой инфраструктуры
terraform destroy
```

### Переменные окружения (альтернатива terraform.tfvars)
```bash
export TF_VAR_yc_token="YOUR_TOKEN"
export TF_VAR_yc_cloud_id="YOUR_CLOUD_ID"
export TF_VAR_yc_folder_id="YOUR_FOLDER_ID"
export TF_VAR_db_password="STRONG_PASSWORD"
```
