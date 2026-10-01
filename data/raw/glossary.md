# Glosario — Adversidad

Este glosario define la terminología oficial utilizada en el ecosistema de Adversidad Hotelera.

El objetivo es estandarizar la interpretación entre los siguientes equipos:
- Revenue
- Planning
- Control
- Sourcing / Travel Partners
- BI
- Reportes operativos
- Proveedores y socios externos

---

## Pricepoint

Unidad mínima de medición competitiva.

Representa una combinación específica de:
- hotel
- dominio / POS
- AP (advance purchase)
- LOS (length of stay)

Cada pricepoint representa un escenario concreto de compra sobre el cual se evalúa competitividad tarifaria.

**Clave técnica:** `pricepoint_id` = reporte + hotel_id + dominio + fecha_crawleo + ap + los + proveedor_tarifa

---

## Ponderador (`weight`)

Valor numérico que representa la importancia relativa de un pricepoint dentro del mercado.

La construcción del ponderador considera:
- representatividad de GB (Good Base) propio
- relevancia inferida de Booking

La relevancia de Booking se infiere utilizando señales basadas en reviews hoteleras.

El ponderador es el denominador de la fórmula de adversidad. Un pricepoint con ponderador alto tiene mayor peso en el resultado final.

> **Cambio importante:** El 2026-05-04 se actualizó la metodología del ponderador. Comparaciones históricas antes y después de esa fecha requieren consideración especial. Ver `changelog.md`.

---

## BML

Clasificación que determina competitividad tarifaria de Despegar frente al competidor para un pricepoint dado.

Valores posibles:
- **BEAT:** Despegar es más de un 1% más barato que el competidor
- **MEET:** La diferencia es de ±1% o menos
- **LOSE:** Despegar es más de un 1% más caro que el competidor

Existen dos versiones del campo BML:
- `basebml`: calculado sobre el precio base (uso operativo, Sourcing/TTPP)
- `finalbml`: calculado sobre el precio total con todos los fees (uso oficial, Revenue KPI)

---

## Adversidad Base

Métrica calculada usando el campo `basebml`. Representa la proporción ponderada de pricepoints donde Despegar pierde en precio base.

**Uso:** Sourcing y Travel Partners para gestión operativa y negociaciones hoteleras.

**Fórmula:**
```
SUM(CASE WHEN basebml = 'LOSE' THEN weight END) / SUM(weight)
```

---

## Adversidad Final

Métrica calculada usando el campo `finalbml`. Representa la proporción ponderada de pricepoints donde Despegar pierde en precio total (incluyendo todos los fees, descuentos y Booking Pays).

**Uso:** KPI corporativo oficial de Revenue.

**Fórmula:**
```
SUM(CASE WHEN finalbml = 'LOSE' THEN weight END) / SUM(weight)
```

---

## Feed

Conjunto de pricepoints enviados a medición en un período determinado.

El feed define:
- universo competitivo
- cobertura de hoteles
- escenarios de compra
- alcance operativo de la medición

Tipos de feed:
- **Revenue:** feed oficial para el KPI corporativo y seguimiento ejecutivo
- **TTPP:** feed complementario utilizado por Travel Partners / Sourcing para fines operativos. No forma parte del KPI corporativo.

---

## Contexto

Condición de acceso o login bajo la cual se ejecuta el crawling competitivo.

Ejemplos:
- `Public`
- `Genius 1`
- `Genius 2`
- `Genius 3`

El benchmark oficial del KPI corporativo utiliza `Genius 1` (también llamado `Genius L1`).

---

## Disponibilidad (`availability`)

Indica si Despegar y/o el competidor tienen oferta disponible para el pricepoint medido.

Valores posibles:
- `Both`: ambos tienen disponibilidad. **La métrica oficial requiere este valor.**
- `Despegar`: solo Despegar tiene disponibilidad
- `Competitor`: solo el competidor tiene disponibilidad
- `None`: ninguno tiene disponibilidad

Si alguna de las partes no posee disponibilidad, el pricepoint queda excluido del cálculo oficial.

> **Nota de compatibilidad:** En la tabla legacy (`bi_rev_adversas_hoteles_pon`) el campo se llama `disponibilidad` y el valor equivalente es `'Ambos'`. En el nuevo modelo relacional (`bi_rev_adversity_hotels_h`) el campo se llama `availability` y el valor es `'Both'`.

---

## pp_is_okr

Campo booleano que identifica si el pricepoint pertenece al universo oficial definido como relevante para el KPI corporativo.

- `1`: el pricepoint es parte del universo OKR
- `0`: el pricepoint está fuera del universo OKR

La métrica oficial solo incluye pricepoints con `pp_is_okr = 1`.

---

## AP (Advance Purchase)

Distancia en días entre la fecha de crawleo y la fecha de check-in del pricepoint.

Campo: `advance` en `bi_rev_adversity_hotels_h`.

---

## LOS (Length of Stay)

Cantidad de noches de estadía medidas para un pricepoint.

Campo: `los` en `bi_rev_adversity_hotels_h`.

---

## pricepoint_id

Identificador técnico único del pricepoint.

Se construye como la concatenación de:
`nombre_reporte + dominio + fecha_crawleo + hotel_id + los + ap + proveedor_tarifa`

Es la clave primaria de las tres tablas del modelo relacional.

---

## fk_hsm

Clave de join para conectar con las tablas de HSM (portfolio de alojamientos de Sourcing BI).

Es igual a `pricepoint_id` pero **sin el campo proveedor_tarifa**, lo que permite un join 1:N: un pricepoint puede tener múltiples proveedores internos compitiendo en Despegar, pero un único registro en HSM.

Campo presente en `bi_rev_adversity_hotels_h`.

---

## travel_type

Indica si el viaje es de tipo nacional o internacional.

Se determina comparando el dominio (POS) con el país destino del hotel:
- `NAC`: el dominio y el país del hotel coinciden (viaje nacional)
- `INT`: el dominio y el país del hotel son distintos (viaje internacional)

---

## partner_offer

Indica si el competidor (Booking) está ofreciendo una Partner Offer para ese pricepoint.

Una Partner Offer es una tarifa exclusiva negociada directamente entre Booking y el hotel, generalmente más agresiva que las tarifas estándar. Su presencia puede explicar pérdidas de competitividad de Despegar que no son atribuibles a la tarifa base.

Campo presente en `bi_rev_adversity_hotels_h`.

---

## preferred_program_competitor

Indica si el hotel está incluido en el programa de preferentes del competidor (ej. Preferred Partner Program de Booking).

Los hoteles en este programa pueden recibir mayor visibilidad, tarifas especiales o condiciones comerciales diferenciadas en la plataforma del competidor.

Campo presente en `bi_rev_adversity_hotels_h`.

---

## Booking Pays

Monto subsidiado por Booking.com para reducir el precio visible al usuario, sin que el hotel modifique su tarifa.

Este monto se incluye en el `total_price_competitor`, lo que hace que la comparación en `finalbml` ya contemple este subsidio.

Campo: `booking_pays` en `bi_rev_adversity_hotels_s_rates`.

---

## Tabla legacy vs. modelo relacional

| Aspecto | Tabla legacy | Nuevo modelo relacional |
|---|---|---|
| Tabla | `lake.bi_rev_adversas_hoteles_pon` | `lake.bi_rev_adversity_hotels_h` + `_s_rates` + `_s_roompack` |
| Estado | `active_to_be_deprecated` | Activo y en evolución |
| Uso recomendado | Consultas históricas o KPI estándar | Análisis detallado de precios y atributos de habitación |
| Campo disponibilidad | `disponibilidad = 'Ambos'` | `availability = 'Both'` |
| Campo día semana | `dia_semana_reporte = 'Tuesday'` | `report_day_of_week = 'Tuesday'` |
| Campo reporte | `nombre_reporte = 'Booking Genius L1'` | `name_report = 'Booking Genius L1'` |
