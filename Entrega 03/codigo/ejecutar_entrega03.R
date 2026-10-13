# Ejecutar desde la RAÍZ del repositorio (no desde Entrega 03).
archivo_mvp <- file.path("Entrega 02", "riesgo_operacional_mvp.R")
archivo_monitor <- file.path("Entrega 03", "codigo", "monitoreo_mvp.R")
if (!file.exists(archivo_mvp) || !file.exists(archivo_monitor)) {
  stop("Abra la raíz del repositorio en Positron; se requieren carpetas 'Entrega 02' y 'Entrega 03'.")
}
# Ejecuta el MVP original, sin cambiar sus reglas.
source(archivo_mvp, encoding = "UTF-8")
source(archivo_monitor, encoding = "UTF-8")
destino <- file.path("Entrega 03", "reportes")
dir.create(destino, recursive = TRUE, showWarnings = FALSE)
write.csv(metricas, file.path(destino, "metricas_monitoreo.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(prioridades, file.path(destino, "prioridades_monitoreo.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(resultado_final, file.path(destino, "controles_priorizados.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("\nENTREGA 03: REPORTES GENERADOS CORRECTAMENTE EN ", destino, "\n", sep = "")
