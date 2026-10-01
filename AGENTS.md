# Workspace Revenue: instrucciones para Codex

Este workspace esta pensado para analisis de datos, automatizaciones livianas y entregables ejecutivos del equipo de Revenue.

## Como trabajar aca

- Prioriza flujos reproducibles sobre respuestas de chat efimeras.
- Antes de concluir, pedi inventario de fuentes y revisa la estructura del proyecto.
- Deja siempre rastro de SQL, scripts, joins, supuestos y outputs relevantes.
- Separa exploracion, transformacion y entregable final.
- Si una tarea se repite, propon convertirla en script o template reutilizable.

## Reglas de datos

- `data/raw` contiene insumo original. Nunca lo sobrescribas.
- `data/interim` contiene joins, cruces y tablas intermedias.
- `data/processed` contiene bases curadas listas para analisis.
- `data/exports` contiene exportaciones desde Metabase, SQL u otras fuentes.
- Si modificas una definicion de negocio o una metrica, documentalo en `docs/decisions`.

## Reglas de trabajo

- Explicita joins, filtros, supuestos y limitaciones cuando afecten el resultado.
- No dejes logica critica solo en la conversacion.
- Guarda SQL reutilizable en `sql/queries` o `sql/templates`.
- Guarda scripts por tipo de tarea en `scripts/`.
- Guarda hallazgos y decisiones en `docs/`.
- Guarda resultados compartibles en `output/ready_to_share` o `presentaciones/final`.

## Formato esperado de entregables

- Un analista nuevo debe poder reconstruir el trabajo leyendo la carpeta.
- Si hay un deck o memo final, tambien debe existir la base analitica que lo respalda.
- Si detectas riesgos de calidad de datos o definiciones ambiguas, senalalos antes de cerrar.

## Nota de contexto

Este archivo cumple el rol de instrucciones globales del workspace en Codex.
Es equivalente conceptual a `CLAUDE.md` en el esquema original del paper y de `# Tu Primer Workspace`.
