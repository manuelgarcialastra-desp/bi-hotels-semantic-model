/*
  Métrica: Adversidad / Adversity
  Nombre técnico: adversity_rate
  Owner: Revenue Innovation
  Tabla fuente: lake.bi_rev_adversity_hotels_h (nuevo modelo relacional)

  Nota: la tabla lake.bi_rev_adversas_hoteles_pon está DEPRECADA.
  Usar siempre el nuevo modelo relacional.

  KPI corporativo oficial:
  - Usa finalbml
  - Booking Genius L1
  - Feed Revenue únicamente
  - Benchmark martes
  - Solo pricepoints OKR
  - Solo disponibilidad comparable (Both)
*/

-- ─────────────────────────────────────────────────────────────────────────────
-- Adversidad mensual — nuevo modelo (usar siempre este)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    year,
    month,

    -- Vista operativa: Sourcing / Travel Partners
    SUM(CASE WHEN basebml = 'LOSE' THEN weight ELSE 0 END)
        / SUM(weight) AS adversidad_base,

    -- KPI corporativo oficial: Revenue
    SUM(CASE WHEN finalbml = 'LOSE' THEN weight ELSE 0 END)
        / SUM(weight) AS adversidad_final

FROM lake.bi_rev_adversity_hotels_h

WHERE crawling_date     >= DATE '2026-01-01'
  AND name_report        = 'Booking Genius L1'
  AND source_feed        = 'Revenue'
  AND report_day_of_week = 'Tuesday'
  AND pp_is_okr          = 1
  AND availability       = 'Both'

GROUP BY
    year,
    month

ORDER BY
    year,
    month;


-- ─────────────────────────────────────────────────────────────────────────────
-- Adversidad con causa raíz — join con Tipificador
-- ─────────────────────────────────────────────────────────────────────────────
WITH base AS (
    SELECT
        h.year,
        h.month,
        h.domain,
        t.root_cause,
        h.weight,
        h.finalbml
    FROM lake.bi_rev_adversity_hotels_h h
    JOIN lake.bi_rev_tipificador t ON h.pricepoint_id = t.pricepoint_id
    WHERE h.crawling_date     >= DATE '2026-01-01'
      AND h.name_report        = 'Booking Genius L1'
      AND h.source_feed        = 'Revenue'
      AND h.report_day_of_week = 'Tuesday'
      AND h.pp_is_okr          = 1
      AND h.availability       = 'Both'
)
SELECT
    year,
    month,
    domain,
    root_cause,
    SUM(weight)                                                             AS peso_total,
    SUM(CASE WHEN finalbml = 'LOSE' THEN weight ELSE 0 END) / SUM(weight)  AS adversidad_final
FROM base
GROUP BY year, month, domain, root_cause
ORDER BY year, month, domain, adversidad_final DESC;


/*
  REFERENCIA DE MIGRACIÓN — tabla legacy DEPRECADA
  ─────────────────────────────────────────────────
  Mapeo de filtros obligatorios:

    ANTES (legacy)                        AHORA (nuevo modelo)
    disponibilidad = 'Ambos'          →   availability = 'Both'
    nombre_reporte = 'Booking...'     →   name_report = 'Booking...'
    dia_semana_reporte = 'Tuesday'    →   report_day_of_week = 'Tuesday'
    source_feed = 'Revenue'           →   source_feed = 'Revenue'  (sin cambio)
    pp_is_okr = 1                     →   pp_is_okr = 1            (sin cambio)
    ponderador                        →   weight
    fecha_crawleo                     →   crawling_date

  Ver mapeo completo en: data/raw/mapeo_campos.xlsx
*/
