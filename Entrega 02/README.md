# Entrega 02 – MVP de Riesgo Operacional en R

**Autor:** Gonzalo Gallardo  
**Curso:** Finanzas en R  
**Entrega:** Producto Mínimo Viable (MVP)

## Objetivo

Implementar en R un MVP que apoye la revisión y priorización de riesgos y controles de Riesgo Operacional. El flujo parte desde el riesgo, calcula su criticidad mediante probabilidad e impacto, revisa los controles asociados, genera alertas y entrega una prioridad de revisión trazable.

El MVP es una herramienta de apoyo al análisis: la priorización no reemplaza el juicio profesional ni corresponde a un modelo predictivo.

## Funcionamiento

1. Construcción del universo de riesgos y controles dentro del propio script.
2. Cálculo del puntaje de riesgo: `probabilidad × impacto`.
3. Clasificación del nivel de riesgo: Crítico, Alto, Medio o Bajo.
4. Validación de la asociación entre riesgos y controles.
5. Revisión de evidencia, resultado del control, plan de acción, estado del plan y tipo de ejecución.
6. Generación de alertas interpretables.
7. Cálculo de un puntaje de prioridad y clasificación Alta / Media / Baja.
8. Generación de tablas y gráficos para apoyar la revisión.
9. Validaciones automáticas de integridad y coherencia antes de finalizar la ejecución.

## Regla de priorización

El puntaje de prioridad parte del puntaje del riesgo y agrega ponderaciones cuando se presentan condiciones que requieren mayor atención:

- Riesgo crítico: +3.
- Control sin evidencia: +3.
- Revisión distinta de satisfactoria: +2.
- Resultado deficiente: +3 adicionales.
- Plan de acción vencido: +3.
- Control manual: +1.

La clasificación final es:

- **Alta:** puntaje >= 25.
- **Media:** puntaje entre 15 y 24.
- **Baja:** puntaje < 15.

Estas ponderaciones constituyen una regla transparente del MVP y pueden calibrarse en versiones posteriores.

## Archivos principales

```text
Entrega 02/
├── riesgo_operacional_mvp.R   # Código principal y autocontenido del MVP
├── reporte_mvp.qmd            # Reporte reproducible desarrollado en Quarto
├── reporte_mvp.html           # Reporte final HTML autocontenido
├── README.md                  # Descripción, metodología y guía de ejecución
├── renv.lock                  # Versiones registradas de los paquetes
└── reporte_mvp_files/         # Recursos generados durante el renderizado
```

## Cómo ejecutar el MVP

Desde la carpeta raíz del proyecto:

```r
source("riesgo_operacional_mvp.R")
```

Al finalizar, la consola debe mostrar `MVP EJECUTADO CORRECTAMENTE` y el resumen de riesgos, controles y prioridades.

## Reporte Quarto

Con las dependencias instaladas, el reporte puede generarse desde Positron/Quarto o mediante:

```bash
quarto render reporte_mvp.qmd
```

El archivo `reporte_mvp.html` incluido en la entrega contiene una versión renderizada del reporte.

## Reproducibilidad con renv

En otro equipo, abrir el proyecto y ejecutar:

```r
renv::restore()
```

Esto restaura las versiones de los paquetes de R registradas en `renv.lock`. Para generar el reporte se requiere además una instalación de Quarto disponible en el sistema.

## Validaciones incorporadas

El script comprueba automáticamente, entre otros puntos:

- IDs de riesgos y controles sin duplicados.
- Probabilidad e impacto dentro de la escala 1–5.
- Correcto cálculo de `probabilidad × impacto`.
- Controles asociados a riesgos existentes.
- Coherencia entre existencia y estado de planes de acción.
- Resultados deficientes con plan de acción.
- Puntajes de prioridad completos y categorías válidas.

## Resultado esperado

El MVP entrega una priorización explicable de los controles que requieren mayor atención, permitiendo al analista concentrar la revisión en los casos más relevantes y conocer las alertas que originan cada prioridad.
