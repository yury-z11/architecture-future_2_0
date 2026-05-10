---
title: "MS SQL Server 2008"
ring: hold
quadrant: tools
tags:
  - data
  - storage
  - legacy
---

MS SQL Server 2008 — текущий монолитный DWH компании. End-of-life платформа без поддержки вендора.

*Причины отказа:*
- End-of-life: отсутствие security patches с 2019 года — регуляторный риск.
- Не масштабируется горизонтально при объёмах сотни ТБ.
- Вся бизнес-логика в одном месте — тормоз для независимого развития доменов.
- Замена: Data Lakehouse (Spark + Delta Lake) + ClickHouse для аналитики.
