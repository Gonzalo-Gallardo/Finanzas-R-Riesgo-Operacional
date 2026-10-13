# Plan de pruebas y aceptación — Entrega 03

Se distingue entre **evidencia histórica de ejecución local** y **pruebas nuevas que deben ejecutarse**. La presencia de un script no acredita su ejecución.

| Prueba | Resultado esperado | Evidencia / estado |
|---|---|---|
| MVP e integración | 10 riesgos, 12 controles y 12 filas finales | Ejecución local anterior informada desde Positron; repetir con el paquete definitivo |
| Distribución de prioridad | Alta 2, Media 6, Baja 4 | Ejecución local anterior; repetir |
| Indicadores | 4 sin evidencia, 2 deficientes, 1 plan vencido | Pruebas de regresión incorporadas; repetir |
| CSV | Tres reportes generados y leídos sin errores | Pruebas de integración incorporadas; repetir |
| IDs duplicados y vacíos | Rechazo | Pruebas negativas nuevas; ejecución pendiente |
| Escala inválida o decimal | Rechazo | Pruebas negativas nuevas; ejecución pendiente |
| Control con riesgo inexistente | Rechazo | Pruebas negativas nuevas; ejecución pendiente |
| Riesgo sin controles | Rechazo por defecto; reporte opcional | Pruebas negativas nuevas; ejecución pendiente |
| Deficiente sin plan de acción | Rechazo cuando se incluyen campos de revisión y plan | Validador auxiliar y prueba negativa nueva; ejecución pendiente |
| Render de Quarto | HTML completo sin error | HTML original generado previamente; regeneración definitiva pendiente |
| `renv` y publicación | Dependencias consistentes y rutas disponibles | Configuración incluida; comprobar en repositorio integrado |

## Ejecución desde la raíz del repositorio

```r
renv::status()
source("Entrega 03/codigo/pruebas_negativas.R")
source("Entrega 03/codigo/pruebas_entrega03.R")
source("Entrega 03/codigo/verificar_publicacion.R")
system2("quarto", c("render", shQuote("Entrega 03/reporte_final.qmd")))
```

La verificación de publicación requiere que `Entrega 01/` y `Entrega 02/riesgo_operacional_mvp.R` estén presentes; **no están incluidas en este paquete de actualización**. El validador auxiliar es una propuesta para ingesta externa futura; el MVP actual utiliza sus validaciones propias. El monitoreo histórico y el despliegue productivo no se consideran ejecutados.
