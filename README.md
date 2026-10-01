# Template - Workspace Revenue

Template simple para que cualquier analista del equipo copie una carpeta base, la renombre y arranque a trabajar con Codex sin tener que inventar estructura ni contexto desde cero.

## Para que sirve

Este template ordena el trabajo en cuatro capas:

1. instrucciones globales para Codex;
2. contexto puntual del caso;
3. referencias estables del frente;
4. datos, scripts y outputs del trabajo.

La logica viene del paper de workspace por capas, adaptada a un uso simple de Revenue.

## Primeros 5 minutos

1. Copia esta carpeta y cambiale el nombre segun tu proyecto.
2. Completa `CONTEXT.md` con la pregunta, el entregable y las fuentes.
3. Completa `REFERENCES.md` solo con lo esencial que ya sepas.
4. Deja los archivos fuente en `data/raw` o `data/exports`.
5. Abre la carpeta en Codex y arranca con uno de los prompts sugeridos.

## Archivos base de contexto

- `AGENTS.md`: le dice a Codex como trabajar en este workspace.
- `CONTEXT.md`: describe el caso puntual que estas resolviendo ahora.
- `REFERENCES.md`: deja definiciones, metricas, links y convenciones estables.

Nota: en el material original de Claude esto aparece como `CLAUDE.md` + `CONTEXT.md` + `REFERENCES.md`. En este template usamos `AGENTS.md` porque el equipo trabaja principalmente con Codex.

## Estructura de carpetas

```text
Template - Workspace Revenue/
+-- AGENTS.md                      # Instrucciones globales para Codex
+-- CONTEXT.md                     # Contexto del caso puntual
+-- REFERENCES.md                  # Referencias estables del frente
+-- README.md                      # Guia rapida de uso
+-- .gitignore                     # Basura temporal y archivos locales
+-- data/
|   +-- raw/                       # Insumo original, no se sobrescribe
|   +-- interim/                   # Joins y tablas intermedias
|   +-- processed/                 # Base curada para analisis
|   '-- exports/                   # Exportaciones desde SQL, Metabase u otros
+-- sql/
|   +-- queries/                   # Queries usadas o listas para rerun
|   +-- templates/                 # SQL reusable o parametrizable
|   '-- scratch/                   # Borradores rapidos
+-- scripts/
|   +-- extraction/                # Descarga o lectura de fuentes
|   +-- transformation/            # Limpieza, joins, enriquecimiento
|   +-- analysis/                  # Analisis, tablas, cuantificaciones
|   '-- reporting/                 # Memos, exports, graficos, decks
+-- docs/
|   +-- brief/                     # Pedido original y framing
|   +-- notes/                     # Hallazgos, dudas y validaciones
|   '-- decisions/                 # Supuestos y decisiones metodologicas
+-- output/
|   +-- tables/                    # Tablas finales o intermedias
|   +-- charts/                    # Graficos listos para usar
|   +-- docs/                      # Memos, resumenes, narrativas
|   '-- ready_to_share/            # Paquete final listo para enviar
+-- presentaciones/
|   +-- drafts/                    # Borradores de slides
|   '-- final/                     # Version final para compartir
'-- setup/
    +-- env_example.txt            # Variables de entorno de referencia
    +-- source_inventory.md        # Inventario de fuentes
    '-- checklist_cierre.md        # Control minimo antes de cerrar
```

## Donde guardar cada cosa

- Datos originales: `data/raw`
- Exports desde sistemas: `data/exports`
- Bases intermedias: `data/interim`
- Bases finales: `data/processed`
- SQL: `sql/queries`, `sql/templates` o `sql/scratch`
- Python o scripts: `scripts/`
- Pedido, notas y decisiones: `docs/`
- Tablas, graficos y memo final: `output/`
- Presentaciones: `presentaciones/`

Si usas notebooks, guardalos dentro de `scripts/analysis` o en una subcarpeta clara dentro de esa ruta.

## Tres prompts para arrancar con Codex

### Prompt 1: ordenar el caso

```text
Lee AGENTS.md, CONTEXT.md y REFERENCES.md. Revisa la estructura de la carpeta y proponeme un plan de trabajo corto para responder la pregunta de negocio.
```

### Prompt 2: inventariar fuentes

```text
Revisa data/, sql/ y docs/. Armame un inventario de fuentes, riesgos de calidad y proximos pasos antes de hacer conclusiones.
```

### Prompt 3: cerrar el analisis

```text
Revisa scripts, sql, docs y output. Decime si otra persona podria reconstruir este trabajo y que falta dejar listo para compartir.
```

## Criterio simple de calidad

Si otra persona no puede reconstruir el trabajo leyendo la carpeta, el analisis no esta bien cerrado.
