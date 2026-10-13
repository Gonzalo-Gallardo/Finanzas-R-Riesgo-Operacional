# Plan de pruebas y aceptación — Entrega 03

Se distingue entre las pruebas ejecutadas y superadas localmente en Positron, las comprobaciones documentales y las funcionalidades futuras no implementadas. La ejecución local del proyecto final informó pruebas de integración y negativas superadas, además de la generación del HTML. Esto no acredita despliegue productivo.

| Prueba | Resultado esperado | Evidencia / estado |
|---|---|---|
| MVP e integración | 10 riesgos, 12 controles y 12 filas finales | Superada en Positron en la ejecución final |
| Distribución de prioridad | Alta 2, Media 6, Baja 4 | Superada en Positron en la ejecución final |
| Indicadores | 4 sin evidencia, 2 deficientes, 1 plan vencido | Pruebas de regresión superadas en Positron |
| CSV | Tres reportes generados y leídos sin errores | Pruebas de integración superadas en Positron |
| IDs duplicados y vacíos | Rechazo | Pruebas negativas nuevas; superada en Positron |
| Escala inválida o decimal | Rechazo | Pruebas negativas nuevas; superada en Positron |
| Control con riesgo inexistente | Rechazo | Pruebas negativas nuevas; superada en Positron |
| Riesgo sin controles | Rechazo por defecto; reporte opcional | Pruebas negativas nuevas; superada en Positron |
| Deficiente sin plan de acción | Rechazo cuando se incluyen campos de revisión y plan | Validador auxiliar y prueba negativa nueva; superada en Positron |
| Render de Quarto | HTML completo sin error | HTML original generado previamente; regeneración definitiva completada en Positron |
| `renv` y publicación | Dependencias consistentes y rutas disponibles | renv consistente en Positron; HTML publicado en GitHub |

## Ejecución desde la raíz del repositorio

```r
renv::status()
source("Entrega 03/codigo/pruebas_negativas.R")
source("Entrega 03/codigo/pruebas_entrega03.R")
source("Entrega 03/codigo/verificar_publicacion.R")
system2("quarto", c("render", shQuote("Entrega 03/reporte_final.qmd")))
```

La verificación de publicación requiere que `Entrega 01/` y `Entrega 02/riesgo_operacional_mvp.R` estén presentes; **no están incluidas en este paquete de actualización**. El validador auxiliar es una propuesta para ingesta externa futura; el MVP actual utiliza sus validaciones propias. El monitoreo histórico y el despliegue productivo no se consideran ejecutados. La comprobación de publicación en GitHub no sustituye la validación local del contenido completo del HTML.
