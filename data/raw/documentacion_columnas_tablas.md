# Documentación de Tablas — Modelo de Datos Revenue Adversas

Este archivo documenta las tres tablas del modelo relacional de Adversidad Hotelera.
Es el reemplazo estructurado del archivo `documentacion_columnas_tablas.csv`.

> **Nota:** Estas tablas conforman el modelo relacional nuevo que reemplaza progresivamente a `lake.bi_rev_adversas_hoteles_pon` (tabla legacy, marcada como deprecated).

---

## Tabla 1: `lake.bi_rev_adversity_hotels_h`

**Propósito:** Tabla principal (header/maestro) del modelo relacional. Contiene la información de identificación, contexto de medición, resultado competitivo (BML), precios mínimos agregados, ponderador y datos de gestión comercial para cada pricepoint medido.

**Granularidad:** Un registro por pricepoint medido (combinación de reporte + hotel + dominio + AP + LOS + proveedor).

**Clave primaria:** `pricepoint_id`

**Clave de join a HSM:** `fk_hsm` (igual a `pricepoint_id` pero sin el proveedor, permite joins 1:N con tablas de HSM)

**Relaciones:**
- Se puede joinear con `bi_rev_adversity_hotels_s_rates` por `pricepoint_id` (1:1)
- Se puede joinear con `bi_rev_adversity_hotels_s_roompack` por `pricepoint_id` (1:1)
- Se puede joinear con tablas de HSM (portfolio de alojamientos de Sourcing BI) por `fk_hsm`

---

### Columnas de identificación

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `pricepoint_id` | varchar | Identificador técnico único del pricepoint. Se construye como la concatenación de: nombre_reporte + dominio + fecha_crawleo + hotel_id + los + ap + proveedor | — |
| `fk_hsm` | varchar | Igual a `pricepoint_id` pero **sin el proveedor**. Se usa para joinear 1:N con las tablas de HSM (portfolio de alojamientos de Sourcing BI). | — |
| `name_report` | varchar | Nombre del reporte. Es la concatenación de competidor y contexto. Ejemplo: `Booking Genius L1` | — |
| `competitor` | varchar | Competidor crawleado en esta medición. | `booking`, `almundo`, `hoteis.com`, `expedia`, `tiquetesbaratos`, `viajesexito`, `pricetravel` |
| `context` | varchar | Condición de acceso o login bajo la cual se ejecutó el crawling competitivo. | `Public`, `Genius 1`, `Genius 2`, `Genius 3` |
| `domain` | varchar | Mercado (POS) desde el cual se realizó el crawleo. | `AR`, `BR`, `MX`, `CL`, `CO`, `PE` |
| `source_feed` | varchar | Feed al que pertenece el pricepoint. Define el universo competitivo y el alcance operativo de la medición. | `Revenue`, `TTPP` |
| `pp_is_okr` | integer | Indicador booleano. Identifica si el pricepoint pertenece al universo oficial relevante para el KPI corporativo. | `1` (incluido), `0` (excluido) |

---

### Columnas de fechas y tiempo

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `crawling_date` | date | Fecha en la que se crawleó el pricepoint. | — |
| `report_date_time_despegar` | timestamp(6) with time zone | Timestamp exacto en el que se crawleó la API de Despegar. | — |
| `report_date_time_competitor` | timestamp(6) with time zone | Timestamp exacto en el que se crawleó la web del competidor. | — |
| `week_year` | varchar | Concatenación de año y número de semana del `crawling_date`. Formato: `YYYY-WW`. Ejemplo: `2024-38` | — |
| `year` | integer | Año del crawleo. | — |
| `month` | integer | Mes del crawleo (1-12). | — |
| `report_day_of_week` | varchar | Día de la semana del crawleo, en inglés. | `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday` |

---

### Columnas de hotel y geografía

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `hotel_despegar_id` | varchar | ID del hotel dentro del portfolio de alojamientos de Despegar. | — |
| `hotel_despegar_name` | varchar | Nombre normalizado del hotel en el portfolio de Despegar. | — |
| `hotel_competitor_id` | varchar | ID del hotel dentro del portfolio del competidor. | — |
| `hotel_competitor_name` | varchar | Nombre normalizado del hotel en el portfolio del competidor. | — |
| `country_code` | varchar | Código IATA del país destino. | `AR`, `BR`, `MX`, `CL`, `CO`, `PE`, etc. |
| `country` | varchar | Nombre del país destino en minúsculas. | — |
| `city_code` | varchar | Código de ciudad (CodigoCiudad). | — |
| `city` | varchar | Nombre de la ciudad destino en minúsculas. | — |
| `chain` | varchar | Nombre de la cadena hotelera a la que pertenece el alojamiento. Ejemplos: `Hilton`, `Riu Hotels and Resorts`. | — |
| `area` | varchar | Área de gestión comercial asignada. | — |
| `market` | varchar | Mercado de gestión comercial asignado. | — |

---

### Columnas de escenario de compra

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `advance` | integer | Días de anterioridad con la que se realizó la búsqueda respecto al `crawling_date` (AP: advance purchase). | — |
| `los` | integer | Cantidad de noches de estadía medidas para el pricepoint (LOS: length of stay). | — |
| `check_in` | date | Fecha de check-in. Se calcula como `crawling_date + advance`. | — |
| `check_out` | date | Fecha de check-out. Se calcula como `check_in + los`. | — |
| `travel_type` | varchar | Indica si el viaje es nacional o internacional. Se determina comparando `domain` con el país de destino del hotel. | `NAC` (nacional), `INT` (internacional) |

---

### Columnas de disponibilidad y resultado competitivo

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `availability` | varchar | Indica si Despegar y/o el competidor tienen disponibilidad para el pricepoint medido. **La métrica oficial requiere filtrar por `availability = 'Both'`**. | `Both` (ambos disponibles), `Despegar` (solo Despegar), `Competitor` (solo competidor), `None` (ninguno) |
| `provider_despegar` | varchar | Proveedor que ganó la competencia interna de tarifas de Despegar para este pricepoint. | `DESP`, `HBG`, `EXP`, etc. |
| `currency` | varchar | Moneda utilizada para los precios del pricepoint. | — |
| `partner_offer` | varchar | Indica si el competidor (Booking) ofrece una Partner Offer: una tarifa exclusiva negociada con Booking, generalmente más agresiva que las tarifas estándar. Puede explicar pérdidas de competitividad no atribuibles a la tarifa base. | — |
| `preferred_program_competitor` | varchar | Indica si el hotel está incluido en el programa de preferentes del competidor (ej. Preferred Partner de Booking), que puede otorgar mayor visibilidad o tarifas especiales. | — |

---

### Columnas de precios y BML

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `payment_type_despegar` | varchar | Tipo de pago de la tarifa ganadora de Despegar. | `prepaid`, `paid at destination` |
| `base_price_despegar_min` | decimal(28,2) | Precio base mínimo de Despegar. Es el menor valor entre `base_price_despegar_pp` y `base_price_despegar_pad`. | — |
| `base_price_competitor` | double | Precio base estimado del competidor, antes de fees y descuentos. | — |
| `base_price_variation` | double | Variación porcentual del precio base. Fórmula: `(base_price_despegar_min - base_price_competitor) / base_price_competitor`. Solo se calcula cuando ambos tienen disponibilidad y el precio del competidor es > 0. | — |
| `basebml` | varchar | Clasificación BML calculada sobre la **tarifa base** (`base_price`). Es la vista operativa utilizada principalmente por Sourcing y Travel Partners. | `BEAT`, `MEET`, `LOSE` |
| `total_price_despegar_min` | decimal(25,4) | Precio total mínimo de Despegar. Es el menor valor entre `total_price_despegar_pp` y `total_price_despegar_pad`. | — |
| `total_price_competitor` | decimal(15,2) | Precio total final estimado del competidor, incluyendo todos los fees y promociones. Para Booking, incluye el incentivo Booking Pays. | — |
| `total_price_variation` | decimal(38,14) | Variación porcentual del precio total. Se calcula de forma análoga a `base_price_variation`. | — |
| `finalbml` | varchar | Clasificación BML calculada sobre la **tarifa final** (`total_price`). Es el campo oficial para el KPI corporativo de Revenue. | `BEAT`, `MEET`, `LOSE` |
| `weight` | decimal(29,8) | Ponderador del pricepoint. Representa la importancia relativa dentro del mercado. Se construye considerando representatividad de GB propio y relevancia inferida de Booking (basada en señales de reviews hoteleras). | — |

---

### Columnas de screenshots

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `url_despegar` | varchar | URL del screenshot de la pantalla de Despegar recreado y almacenado en S3. Disponible durante 3 meses desde la fecha de crawleo. | — |
| `url_competitor` | varchar | URL del screenshot de la pantalla del competidor recreado y almacenado en S3. Disponible durante 3 meses desde la fecha de crawleo. | — |

---

### Columnas de gestión comercial

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `ops_team` | varchar | Equipo de operaciones comerciales asignado al alojamiento. | — |
| `account_type` | varchar | Tipo de cuenta de gestión comercial del alojamiento. | — |
| `aacc` | varchar | Asesor comercial (Account Executive) asignado al alojamiento. | — |
| `eecc` | varchar | Ejecutivo comercial asignado al alojamiento. | — |

---

---

## Tabla 2: `lake.bi_rev_adversity_hotels_s_rates`

**Propósito:** Tabla de detalle de precios. Contiene todos los componentes de precio desagregados para Despegar (PP y PAD) y el competidor: precios base, precios finales, impuestos, fees, descuentos y datos específicos de Booking.

**Granularidad:** Un registro por pricepoint (igual granularidad que `bi_rev_adversity_hotels_h`).

**Clave primaria:** `pricepoint_id`

**Relaciones:**
- Join con `bi_rev_adversity_hotels_h` por `pricepoint_id` (1:1)

---

### Columnas de identificación

| Columna | Tipo | Descripción |
|---|---|---|
| `pricepoint_id` | varchar | Identificador técnico único del pricepoint. Mismo valor que en `bi_rev_adversity_hotels_h`. |
| `crawling_date` | date | Fecha en la que se crawleó el pricepoint. |

---

### Precios base y totales

| Columna | Tipo | Descripción |
|---|---|---|
| `base_price_despegar_pp` | decimal(28,2) | Precio base de Despegar para pago prepago (PP). Incluye el precio del hotel más comisión e impuestos básicos. |
| `base_price_despegar_pad` | decimal(23,2) | Precio base de Despegar para pago en destino (PAD). Incluye el precio del hotel más comisión e impuestos básicos. |
| `base_price_competitor` | double | Precio base estimado del competidor, antes de fees y descuentos. |
| `total_price_despegar_pp` | decimal(23,2) | Precio final de Despegar para PP, incluyendo todos los fees y descuentos aplicados. |
| `total_price_despegar_pad` | decimal(22,2) | Precio final de Despegar para PAD, incluyendo todos los fees y descuentos aplicados. |
| `total_price_competitor` | decimal(15,2) | Precio final estimado del competidor, incluyendo todos los fees y promociones. Para Booking incluye el incentivo Booking Pays. |
| `price_before_promotion_despegar` | decimal(10,2) | Precio de Despegar antes de aplicar cualquier descuento promocional. |
| `price_before_promotion_competitor` | decimal(10,2) | Precio del competidor antes de aplicar cualquier descuento promocional. |

---

### Impuestos y fees de Despegar

| Columna | Tipo | Descripción |
|---|---|---|
| `tax_despegar_pp` | decimal(10,2) | Impuesto aplicado a la tarifa PP. |
| `tax_despegar_pad` | decimal(10,2) | Impuesto aplicado a la tarifa PAD. |
| `commission_tax_despegar_pp` | decimal(10,2) | Impuesto de comisión aplicado a la tarifa PP. |
| `commission_tax_despegar_pad` | decimal(10,2) | Impuesto de comisión aplicado a la tarifa PAD. |
| `iof_fee_despegar_pp` | decimal(10,2) | Fee de IOF (Imposto sobre Operações Financeiras) en la tarifa PP. Impuesto financiero brasileño sobre transacciones internacionales. |
| `iof_fee_despegar_pad` | decimal(10,2) | Fee de IOF en la tarifa PAD. |
| `base_fee_despegar_pp` | decimal(10,2) | Fee de servicio base cobrado por Despegar para el tipo de pago PP. |
| `resort_fee_despegar_pp` | decimal(10,2) | Fee de resort obligatorio cobrado por el hotel, reflejado en la tarifa PP. Cubre acceso a instalaciones como pileta, gimnasio o Wi-Fi. |
| `resort_fee_despegar_pad` | decimal(10,2) | Fee de resort obligatorio cobrado por el hotel, reflejado en la tarifa PAD. |
| `cleaning_fee_despegar_pp` | decimal(10,2) | Fee de limpieza aplicado a la tarifa PP. |
| `cleaning_fee_despegar_pad` | decimal(10,2) | Fee de limpieza aplicado a la tarifa PAD. |
| `service_rate_despegar_pp` | decimal(10,2) | Cargo de servicio aplicado a la tarifa PP. |
| `service_rate_despegar_pad` | decimal(10,2) | Cargo de servicio aplicado a la tarifa PAD. |
| `tourism_fee_despegar_pp` | decimal(10,2) | Tasa o impuesto turístico aplicado a la tarifa PP. |
| `tourism_fee_despegar_pad` | decimal(10,2) | Tasa o impuesto turístico aplicado a la tarifa PAD. |
| `city_tax_despegar_pp` | decimal(10,2) | Impuesto municipal o de ciudad aplicado a la tarifa PP. |
| `city_tax_despegar_pad` | decimal(10,2) | Impuesto municipal o de ciudad aplicado a la tarifa PAD. |
| `service_tax_despegar_pp` | decimal(10,2) | Impuesto de servicio aplicado a la tarifa PP. |
| `service_tax_despegar_pad` | decimal(10,2) | Impuesto de servicio aplicado a la tarifa PAD. |
| `environmental_fee_despegar_pp` | decimal(10,2) | Fee ambiental o de sustentabilidad aplicado a la tarifa PP. |
| `environmental_fee_despegar_pad` | decimal(10,2) | Fee ambiental o de sustentabilidad aplicado a la tarifa PAD. |
| `taxes_at_destination_despegar_pp` | decimal(10,2) | Impuestos pagaderos en destino (al check-in o check-out) para la tarifa PP. |
| `taxes_at_destination_despegar_pad` | decimal(10,2) | Impuestos pagaderos en destino para la tarifa PAD. |
| `hotel_insurance_despegar_pp` | decimal(10,2) | Costo del seguro hotelero incluido en la tarifa PP. |
| `hotel_insurance_despegar_pad` | decimal(10,2) | Costo del seguro hotelero incluido en la tarifa PAD. |
| `amenity_fee_despegar_pp` | decimal(10,2) | Fee por acceso a instalaciones o servicios del hotel, aplicado a la tarifa PP. |
| `amenity_fee_despegar_pad` | decimal(10,2) | Fee por acceso a instalaciones o servicios del hotel, aplicado a la tarifa PAD. |

---

### Descuentos de Despegar

| Columna | Tipo | Descripción |
|---|---|---|
| `commercial_discounts_despegar_pp` | decimal(10,2) | Descuentos comerciales o promocionales aplicados por Despegar a la tarifa PP. |
| `pricematch_discount_despegar_pp` | decimal(10,2) | Descuento de price match aplicado por Despegar a la tarifa PP al igualar un precio menor del competidor. |
| `sa_discount_despegar_pp` | decimal(10,2) | Descuento de Smart Alerts (SA) aplicado a la tarifa PP. |
| `uf_discount_despegar_pp` | decimal(10,2) | Descuento de fidelidad User First (UF) aplicado a la tarifa PP. |

---

### Fees del competidor

| Columna | Tipo | Descripción |
|---|---|---|
| `resort_fee_competitor` | decimal(10,2) | Fee de resort obligatorio según el precio del competidor. |
| `cleaning_fee_competitor` | decimal(10,2) | Fee de limpieza según el precio del competidor. |
| `service_rate_competitor` | decimal(10,2) | Cargo de servicio según el precio del competidor. |
| `tourism_fee_competitor` | decimal(10,2) | Tasa turística según el precio del competidor. |
| `city_tax_competitor` | decimal(10,2) | Impuesto municipal según el precio del competidor. |
| `service_tax_competitor` | decimal(10,2) | Impuesto de servicio según el precio del competidor. |
| `environmental_fee_competitor` | decimal(10,2) | Fee ambiental según el precio del competidor. |
| `taxes_at_destination_competitor` | decimal(10,2) | Impuestos pagaderos en destino según el precio del competidor. |
| `hotel_insurance_competitor` | decimal(10,2) | Costo de seguro hotelero según el precio del competidor. |

---

### Descuentos de Booking (campos específicos)

| Columna | Tipo | Descripción |
|---|---|---|
| `booking_pays` | decimal(10,2) | Monto subsidiado por Booking.com para reducir el precio mostrado. Se incluye en el precio total del competidor. |
| `discount_name_bkg_1` | varchar | Nombre del 1er descuento aplicado por Booking al precio del competidor. |
| `discount_amount_bkg_1` | double | Monto del 1er descuento de Booking. |
| `discount_name_bkg_2` | varchar | Nombre del 2do descuento de Booking. |
| `discount_amount_bkg_2` | double | Monto del 2do descuento de Booking. |
| `discount_name_bkg_3` | varchar | Nombre del 3er descuento de Booking. |
| `discount_amount_bkg_3` | double | Monto del 3er descuento de Booking. |
| `discount_name_bkg_4` | varchar | Nombre del 4to descuento de Booking. |
| `discount_amount_bkg_4` | double | Monto del 4to descuento de Booking. |
| `discount_name_bkg_5` | varchar | Nombre del 5to descuento de Booking. |
| `discount_amount_bkg_5` | double | Monto del 5to descuento de Booking. |
| `discount_name_bkg_6` | varchar | Nombre del 6to descuento de Booking. |
| `discount_amount_bkg_6` | double | Monto del 6to descuento de Booking. |

---

---

## Tabla 3: `lake.bi_rev_adversity_hotels_s_roompack`

**Propósito:** Tabla de atributos de habitación/producto. Contiene información sobre tipo de pago, política de cancelación, tipo de habitación y tipo de pensión (board type) tanto para Despegar (PP y PAD) como para el competidor.

**Granularidad:** Un registro por pricepoint (igual granularidad que `bi_rev_adversity_hotels_h`).

**Clave primaria:** `pricepoint_id`

**Relaciones:**
- Join con `bi_rev_adversity_hotels_h` por `pricepoint_id` (1:1)

---

### Columnas de identificación

| Columna | Tipo | Descripción |
|---|---|---|
| `pricepoint_id` | varchar | Identificador técnico único del pricepoint. Mismo valor que en `bi_rev_adversity_hotels_h`. |
| `crawling_date` | date | Fecha en la que se crawleó el pricepoint. |

---

### Tipo de pago

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `payment_type_despegar` | varchar | Tipo de pago disponible para la oferta de Despegar. | `prepaid`, `paid at destination` |
| `payment_type_competitor` | varchar | Tipo de pago disponible para la oferta del competidor. | `prepaid`, `paid at destination` |

---

### Política de cancelación

| Columna | Tipo | Descripción | Valores posibles |
|---|---|---|---|
| `cancellation_policy_despegar_pp` | varchar | Política de cancelación de Despegar para pago prepago (PP). | `fully_refundable`, `partially_refundable`, `non_refundable` |
| `cancellation_policy_despegar_pad` | varchar | Política de cancelación de Despegar para pago en destino (PAD). | `fully_refundable`, `partially_refundable`, `non_refundable` |
| `cancellation_policy_competitor` | varchar | Política de cancelación del competidor. | `fully_refundable`, `partially_refundable`, `non_refundable` |

> **Nota de negocio:** En el Tipificador de Competitividad, `fully_refundable` y `partially_refundable` se tratan como equivalentes a efectos de comparación de roompack.

---

### Tipo de habitación

| Columna | Tipo | Descripción |
|---|---|---|
| `roomtype_despegar_pp` | varchar | Nombre o tipo de habitación ofrecida por Despegar en modalidad PP. Texto libre. |
| `roomtype_despegar_pad` | varchar | Nombre o tipo de habitación ofrecida por Despegar en modalidad PAD. Texto libre. |
| `roomtype_competitor` | varchar | Nombre o tipo de habitación ofrecida por el competidor. Texto libre. |

---

### Tipo de pensión (board type)

| Columna | Tipo | Descripción | Códigos y significado |
|---|---|---|---|
| `boardtype_despegar_pp` | varchar | Tipo de mealplan ofrecido por Despegar en modalidad PP. Campo mapeado a códigos estándar. | `A` = All Inclusive, `B` = Desayuno, `BRA` = Desayuno Americano, `BRB` = Desayuno Buffet, `BRC` = Desayuno Continental, `F` = Pensión Completa, `H` = Solo alojamiento, `M` = Media Pensión |
| `boardtype_despegar_pad` | varchar | Tipo de mealplan ofrecido por Despegar en modalidad PAD. Campo mapeado a códigos estándar. | Mismos códigos que `boardtype_despegar_pp` |
| `boardtype_competitor` | varchar | Texto libre que describe el mealplan del competidor. **No está mapeado a códigos**. Frecuentemente incluye información de precios en el texto, lo que se interpreta como "no incluido". | Texto libre sin código estándar |

> **Nota de negocio:** En el Tipificador de Competitividad, las variantes de desayuno (`B`, `BRA`, `BRB`, `BRC`) se tratan como equivalentes a efectos de comparación de roompack.

---

### Tags

| Columna | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `tags_pp` | varchar | Tags disponibles para la opción PP seleccionada. Separados por `\|`. | `free_cancellation\|flexible_cancellation_policy` |
| `tags_pad` | varchar | Tags disponibles para la opción PAD seleccionada. Separados por `\|`. | `free_cancellation\|flexible_cancellation_policy` |
