# Ejecutar desde la carpeta que contiene Entrega 02 y Entrega 03.
source(file.path("Entrega 03", "codigo", "ejecutar_entrega03.R"), encoding = "UTF-8")
stopifnot(nrow(riesgos) == 10L, nrow(controles) == 12L, nrow(resultado_final) == 12L)
stopifnot(!anyDuplicated(riesgos$id_riesgo), !anyDuplicated(controles$id_control))
stopifnot(all(controles$id_riesgo %in% riesgos$id_riesgo))
stopifnot(all(riesgos$puntaje_riesgo == riesgos$probabilidad * riesgos$impacto))
stopifnot(all(resultado_final$prioridad %in% c("Alta", "Media", "Baja")))
stopifnot(sum(prioridades$cantidad) == nrow(resultado_final))
stopifnot(sum(resultado_final$prioridad == "Alta") == 2L)
stopifnot(sum(resultado_final$prioridad == "Media") == 6L)
stopifnot(sum(resultado_final$prioridad == "Baja") == 4L)
stopifnot(all(file.exists(file.path("Entrega 03", "reportes", c(
  "metricas_monitoreo.csv", "prioridades_monitoreo.csv", "controles_priorizados.csv"
)))))
# Pruebas de regresión sobre los indicadores y los archivos publicados.
valor <- function(nombre) metricas$valor[match(nombre, metricas$indicador)]
stopifnot(
  identical(as.integer(valor("riesgos")), 10L),
  identical(as.integer(valor("controles")), 12L),
  identical(as.integer(valor("riesgos_sin_control")), 0L),
  identical(as.integer(valor("controles_sin_evidencia")), 4L),
  identical(as.integer(valor("controles_deficientes")), 2L),
  identical(as.integer(valor("planes_vencidos")), 1L),
  identical(as.integer(valor("ids_control_duplicados")), 0L),
  identical(as.integer(valor("deficientes_sin_plan")), 0L),
  abs(valor("pct_controles_sin_evidencia") - 33.33) < 0.01
)
carpeta_reportes <- file.path("Entrega 03", "reportes")
reporte_prioridad <- read.csv(file.path(carpeta_reportes, "prioridades_monitoreo.csv"),
                             fileEncoding = "UTF-8", stringsAsFactors = FALSE)
reporte_metricas <- read.csv(file.path(carpeta_reportes, "metricas_monitoreo.csv"),
                            fileEncoding = "UTF-8", stringsAsFactors = FALSE)
reporte_controles <- read.csv(file.path(carpeta_reportes, "controles_priorizados.csv"),
                             fileEncoding = "UTF-8", stringsAsFactors = FALSE)
stopifnot(
  nrow(reporte_controles) == 12L,
  nrow(reporte_metricas) == nrow(metricas),
  sum(reporte_prioridad$cantidad) == 12L,
  all(c("Alta", "Media", "Baja") %in% reporte_prioridad$prioridad),
  !anyDuplicated(reporte_controles$id_control)
)
cat("\nPRUEBAS ENTREGA 03: SUPERADAS\n")
