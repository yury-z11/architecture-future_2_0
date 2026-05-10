---
title: "DWH (Data Lakehouse)"
ring: adopt
quadrant: methods-and-patterns
tags:
  - data
  - storage
  - infrastructure
---

Data Lakehouse — архитектурный паттерн, объединяющий гибкость Data Lake и транзакционность DWH на базе открытых форматов (Delta Lake, Iceberg).

*Бизнес-сценарии:*
- Единая аналитическая платформа для всех доменов без монолитного SQL Server.
- Поддержка витрины данных и Self-Service BI портала.
- Хранение исторических данных (сотни ТБ) с быстрым доступом.
