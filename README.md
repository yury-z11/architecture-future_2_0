# architecture-future_2_0

Проектная работа 11-го спринта по кейсу компании **«Будущее 2.0»**. Решение описывает целевую архитектуру работы с данными, доменное разделение, технологический радар, роадмап изменений и пример облачной инфраструктуры на Terraform.

## Краткий результат

- Спроектирована целевая контейнерная архитектура: доменные сервисы, API Gateway, Kafka/Event Bus, Data Platform/Data Lakehouse, Data Catalog и Self-Service BI.
- Выявлены ключевые проблемы текущего ландшафта: монолитный DWH на SQL Server 2008, медленная отчётность, отсутствие доменной изоляции, устаревшие PowerBuilder/ESB и регуляторные риски при смешении данных.
- Предложено разделение на домены: головной офис/аналитика, клиники, финтех, ИИ-сервисы и партнёрские интеграции.
- Описаны целевые потоки данных: домены публикуют события в Kafka, аналитическая платформа строит витрины на обезличенных и агрегированных данных, медицинские карты и результаты исследований не включаются в витрину данных.
- Сформирован технологический радар и 18-месячный роадмап перехода к новой архитектуре.
- Подготовлена Terraform-конфигурация для Yandex Cloud: сеть, public/private подсети, NAT, security groups, VM для API Gateway/Data Platform/Kafka, диск для данных и Managed PostgreSQL.

## Структура проекта

```text
architecture-future_2_0/
├── Task1/                     # C4 Container diagram и приоритизация проблем
├── Task2/                     # DFD и доменное разделение
├── Task3/                     # Технологический радар и роадмап
├── Task4/                     # Terraform + схема автоматизации развёртывания
└── README.md                  # Навигация по результатам проектной работы
```

## Артефакты по заданиям

| Задание | Результат | Основные файлы |
|---|---|---|
| Task1 | Целевая C4 Container-архитектура, список проблем, MoSCoW и матрица Эйзенхауэра | [c4_diagram.png](Task1/c4_diagram.png), [problems_and_priorities.md](Task1/problems_and_priorities.md) |
| Task2 | Доменная модель и DFD потоков данных между клиниками, финтехом, ИИ, партнёрами и аналитикой | [dfd.png](Task2/dfd.png), [domains.md](Task2/domains.md) |
| Task3 | Технологический радар, роадмап изменений и обоснование этапов трансформации | [Future20_TechRoadmap.md](Task3/Future20_TechRoadmap.md), [tech_radar/about.md](Task3/tech_radar/about.md), [flow.md](Task3/flow.md) |
| Task4 | Terraform-проект для облачной инфраструктуры и обоснование выбранной конфигурации | [diagram.png](Task4/diagram.png), [main.tf](Task4/main.tf), [variables.tf](Task4/variables.tf), [outputs.tf](Task4/outputs.tf), [terraform.tfvars](Task4/terraform.tfvars), [justification.md](Task4/justification.md) |

## Ссылки на Markdown-файлы

- **Task1:** [Анализ проблем и приоритизация](Task1/problems_and_priorities.md)
- **Task2:** [Домены и описание потоков данных](Task2/domains.md)
- **Task3:** [Роадмап и обоснование технологических изменений](Task3/Future20_TechRoadmap.md)
- **Task3:** [Инструкция запуска интерактивного техрадара](Task3/flow.md)
- **Task3:** [Описание техрадара](Task3/tech_radar/about.md)
- **Task4:** [Обоснование Terraform-конфигурации](Task4/justification.md)

<details>
<summary>Карточки технологий в интерактивном техрадаре</summary>

- [Apache-DataFusion](Task3/tech_radar/radar/2026-01-19/Apache-DataFusion.md)
- [Greenplum](Task3/tech_radar/radar/2026-01-19/Greenplum.md)
- [Polars](Task3/tech_radar/radar/2026-01-19/Polars.md)
- [apache-camel](Task3/tech_radar/radar/2026-01-19/apache-camel.md)
- [apache-flink](Task3/tech_radar/radar/2026-01-19/apache-flink.md)
- [apache-iceberg](Task3/tech_radar/radar/2026-01-19/apache-iceberg.md)
- [apache-kafka-streams](Task3/tech_radar/radar/2026-01-19/apache-kafka-streams.md)
- [apache-spark](Task3/tech_radar/radar/2026-01-19/apache-spark.md)
- [clickhouse](Task3/tech_radar/radar/2026-01-19/clickhouse.md)
- [cloud-services](Task3/tech_radar/radar/2026-01-19/cloud-services.md)
- [datahub](Task3/tech_radar/radar/2026-01-19/datahub.md)
- [datamesh](Task3/tech_radar/radar/2026-01-19/datamesh.md)
- [delta-lake](Task3/tech_radar/radar/2026-01-19/delta-lake.md)
- [duckdb](Task3/tech_radar/radar/2026-01-19/duckdb.md)
- [dwh](Task3/tech_radar/radar/2026-01-19/dwh.md)
- [golang](Task3/tech_radar/radar/2026-01-19/golang.md)
- [java](Task3/tech_radar/radar/2026-01-19/java.md)
- [langchain](Task3/tech_radar/radar/2026-01-19/langchain.md)
- [minio-s3](Task3/tech_radar/radar/2026-01-19/minio-s3.md)
- [mssql](Task3/tech_radar/radar/2026-01-19/mssql.md)
- [pgsql](Task3/tech_radar/radar/2026-01-19/pgsql.md)
- [power-bi](Task3/tech_radar/radar/2026-01-19/power-bi.md)
- [power-builder](Task3/tech_radar/radar/2026-01-19/power-builder.md)
- [python](Task3/tech_radar/radar/2026-01-19/python.md)
- [snowflake](Task3/tech_radar/radar/2026-01-19/snowflake.md)
- [star-rocks](Task3/tech_radar/radar/2026-01-19/star-rocks.md)
- [trino](Task3/tech_radar/radar/2026-01-19/trino.md)

</details>

## Как запустить интерактивный технологический радар

```bash
cd Task3/tech_radar
npm install
npm run build
npm run serve
# Открыть http://localhost:3000
```

## Как проверить Terraform-проект

```bash
cd Task4
terraform init
terraform validate
terraform plan
terraform apply
```

После успешного `terraform apply` нужно приложить реальный скриншот результата выполнения команды в пул-реквест. В репозитории оставлен шаблон `terraform.tfvars`; для публичного репозитория не коммитьте реальные токены, пароли и ключи.

## Рекомендации перед сдачей

1. **Task4:** добавить в пул-реквест реальный скриншот успешного `terraform apply`. Текущий архив содержит Terraform-код и диаграмму, но скриншот должен быть получен из вашего облачного окружения.
2. **Task3:** усилить роадмап таблицей по каждому этапу: ожидаемый результат, ответственная команда, ресурсы и KPI. Это прямо упростит проверку соответствия требованиям задания.
3. **Task1:** Self-Service BI лучше поднять в приоритете до `Must Have` или явно пояснить, почему он отнесён к `Should Have`, так как портал самообслуживания является одной из центральных бизнес-целей.
4. **Task2:** уточнить формулировку по AI-домену: в общую аналитическую платформу должны попадать только обезличенные агрегаты и технические метрики ИИ, а не медицинские карты, истории болезней или результаты исследований.
5. **Безопасность:** перед публикацией проверить, что в `terraform.tfvars` нет настоящих `yc_token`, `cloud_id`, `folder_id`, SSH-ключей и паролей.

## Итоговая целевая архитектура

Решение переводит компанию от централизованного DWH-монолита к доменной, событийной и масштабируемой архитектуре данных. Новые бизнес-направления подключаются через API Gateway и Kafka без внесения бизнес-логики в единый DWH. Аналитика строится на Data Lakehouse/Self-Service BI с разграничением доступа, а чувствительные медицинские данные остаются изолированными от витрин.
