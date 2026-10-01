# Definición de Métrica — Adversidad

## Nombre técnico
`adversity_rate`

---

## 1. Objetivo

Adversidad es la métrica corporativa utilizada para medir el nivel de competitividad tarifaria frente a OTAs competidores dentro de la vertical de Hoteles.

La métrica busca representar cómo compite Despegar en una muestra representativa de pricepoints relevantes para el mercado.

La métrica es utilizada para:
- Definir estrategias de pricing y descuentos
- Priorizar negociaciones con hoteles
- Monitorear competitividad
- Guiar decisiones de Revenue y Sourcing

---

## 2. Clasificación BML

La clasificación BML (BEAT / MEET / LOSE) se calcula comparando la oferta más barata de Despegar contra la oferta más barata del competidor para el mismo pricepoint.

La comparación asume que ambas ofertas son comercialmente comparables y están disponibles para la venta.

---

### BEAT

Despegar es más de un 1% más barato que el competidor.

```
precio_despegar < precio_competidor × (1 - 0.01)
```

---

### MEET

La diferencia entre Despegar y el competidor es de ±1% o menos (ni gana ni pierde significativamente).

```
precio_competidor × (1 - 0.01) ≤ precio_despegar ≤ precio_competidor × (1 + 0.01)
```

---

### LOSE

Despegar es más de un 1% más caro que el competidor.

```
precio_despegar > precio_competidor × (1 + 0.01)
```

---

## 3. Versiones de la métrica

### Adversidad Base (`basebml`)

- **Campo:** `basebml`
- **Precio de referencia:** precio base (`base_price_despegar_min` vs `base_price_competitor`)
- **Uso principal:** vista operativa para Sourcing y Travel Partners (negociaciones hoteleras)
- **Fórmula:**
  ```sql
  SUM(CASE WHEN basebml = 'LOSE' THEN weight END) / SUM(weight)
  ```

### Adversidad Final (`finalbml`)

- **Campo:** `finalbml`
- **Precio de referencia:** precio total (`total_price_despegar_min` vs `total_price_competitor`), incluyendo todos los fees, descuentos y el incentivo Booking Pays
- **Uso principal:** KPI corporativo oficial de Revenue
- **Fórmula:**
  ```sql
  SUM(CASE WHEN finalbml = 'LOSE' THEN weight END) / SUM(weight)
  ```

> **Regla clave:** El KPI corporativo siempre usa `finalbml`. El campo `basebml` es de uso operativo exclusivamente.

---

## 4. Filtros obligatorios para el KPI oficial

Para calcular la Adversidad oficial, siempre deben aplicarse los siguientes filtros:

| Filtro | Valor | Razón |
|---|---|---|
| `availability` | `Both` | Solo se comparan pricepoints donde ambos (Despegar y competidor) tienen disponibilidad |
| `report_day_of_week` | `Tuesday` | El benchmark oficial es el martes |
| `name_report` | `Booking Genius L1` | El reporte oficial es Booking en contexto Genius 1 |
| `pp_is_okr` | `1` | Solo se incluyen pricepoints del universo OKR |

> **Nota:** En la tabla legacy (`bi_rev_adversas_hoteles_pon`) los nombres de los campos son: `disponibilidad`, `dia_semana_reporte`, `nombre_reporte`, `pp_is_okr`. En el nuevo modelo relacional (`bi_rev_adversity_hotels_h`) son: `availability`, `report_day_of_week`, `name_report`, `pp_is_okr`.

---

## 5. Consumidores

| Equipo | Métrica utilizada | Propósito |
|---|---|---|
| Revenue | Adversidad Final (`finalbml`) | KPI corporativo, seguimiento ejecutivo |
| Sourcing / Travel Partners | Adversidad Base (`basebml`) | Gestión operativa y negociaciones hoteleras |
| Planning | Adversidad Final | Seguimiento de objetivos |
| Accommodations | Ambas | Diagnóstico y priorización |
