# Adversidad

## Technical Name
`adversity_rate`

## Status
Production + Evolving

---

# Overview

Adversidad is the corporate metric used to measure tariff competitiveness against OTA competitors within the Hotels vertical.

The metric represents the weighted share of pricepoints where Despegar loses competitiveness versus competitor OTAs under defined market and context conditions.

This metric is used to:
- Define discount and pricing strategies
- Prioritize hotel negotiations
- Monitor competitiveness performance
- Support executive and operational reporting
- Guide sourcing and travel partner initiatives

---

# Scope

## Vertical
- Hotels only

## Markets / POS
The metric is measured across the following domains:
- AR
- BR
- CO
- CL
- MX

## Competitors by Domain

### Argentina (AR)
- Booking
- Almundo

### Brazil (BR)
- Booking
- Hoteis.com
- Expedia

### Colombia (CO)
- Booking
- TiquetesBaratos
- ViajesExito

### Chile (CL)
- Booking only

### Mexico (MX)
- Booking
- PriceTravel
- Expedia
- Hoteis.com

---

# Competitive Contexts

## Booking
Booking is measured under multiple contexts:
- Public
- Genius 1
- Genius 2
- Genius 3

## Other Competitors
All other competitors are measured under Public context only.

---

# Measurement Frequency

## Daily
- Booking Public
- Booking Genius 1
- PriceTravel

## Tuesdays
- Booking Genius 2
- Booking Genius 3

## Mondays
- Remaining competitors

---

# Revenue vs TTPP Complement

Revenue feed runs continuously as the official corporate measurement source.

Additionally:
- Sundays and Tuesdays include a complementary TTPP feed used for operational purposes.
- The TTPP complement is NOT part of the official corporate KPI calculation.

The official reported metric corresponds to:
- Booking Genius 1
- Revenue feed only
- Tuesday benchmark

---

# Governance

## Business Owner
Revenue Innovation

## Technical Owner
Revenue Innovation BI

## Main Consumer Teams
- Planning
- Revenue
- Sourcing / Travel Partners
- Accommodations

---

# Repository Structure

This repository contains:
- Metric definition
- Technical contract
- SQL reference logic
- Change history
- Validation rules
- Governance documentation

Refer to:
- `metric_contract.yaml`
- `metric_definition.md`
- `sql_reference.sql`
- `changelog.md`

---

# Estado actual del modelo de datos

## Tabla legacy

**Tabla:** `lake.bi_rev_adversas_hoteles_pon`
**Estado:** `active_to_be_deprecated`
**Uso recomendado:** Consultas históricas y cálculo estándar del KPI de adversidad. Es la tabla que actualmente se usa en los reportes productivos.

El SQL canónico sobre esta tabla está documentado en `sql_reference.sql`.

## Nuevo modelo relacional

El modelo relacional reemplaza progresivamente a la tabla legacy. Está compuesto por tres tablas:

| Tabla | Propósito |
|---|---|
| `lake.bi_rev_adversity_hotels_h` | Tabla principal (header/maestro). Contiene identificación del pricepoint, resultado BML, precios mínimos agregados, ponderador y datos de gestión comercial. |
| `lake.bi_rev_adversity_hotels_s_rates` | Detalle de precios desagregados: componentes de precio, impuestos, fees y descuentos para Despegar (PP y PAD) y el competidor. |
| `lake.bi_rev_adversity_hotels_s_roompack` | Atributos de habitación: tipo de pago, política de cancelación, tipo de habitación y tipo de pensión (board type). |

Las tres tablas se joinean por `pricepoint_id`.

La documentación detallada de columnas de estas tablas está en `documentacion_columnas_tablas.md`.

## Diferencias de nomenclatura entre modelos

| Concepto | Tabla legacy | Nuevo modelo |
|---|---|---|
| Disponibilidad | `disponibilidad = 'Ambos'` | `availability = 'Both'` |
| Día de la semana | `dia_semana_reporte` | `report_day_of_week` |
| Nombre del reporte | `nombre_reporte` | `name_report` |
| Fecha de crawleo | `fecha_crawleo` | `crawling_date` |
| Ponderador | `ponderador` | `weight` |