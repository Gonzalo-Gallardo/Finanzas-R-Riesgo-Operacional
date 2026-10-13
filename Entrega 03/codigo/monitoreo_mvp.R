# Monitoreo del MVP. Requiere objetos creados por Entrega 02.
objetos <- c("riesgos", "controles", "resultado_final")
if (!all(vapply(objetos, exists, logical(1), inherits = TRUE))) {
  stop("Ejecute primero riesgo_operacional_mvp.R")
}
campos <- c("id_riesgo", "id_control", "prioridad", "evidencia", "resultado_revision", "estado_plan", "puntaje_prioridad")
if (!all(campos %in% names(resultado_final))) stop("Faltan columnas requeridas en resultado_final")
if (nrow(controles) == 0L || nrow(riesgos) == 0L) stop("Universo de datos vacío")
if (anyNA(riesgos$id_riesgo) || anyNA(controles$id_control)) stop("IDs faltantes")

conteo <- function(x) as.integer(sum(x, na.rm = TRUE))
metricas <- data.frame(
  indicador = c("riesgos", "controles", "riesgos_sin_control", "pct_riesgos_sin_control", "controles_sin_evidencia", "pct_controles_sin_evidencia", "controles_deficientes", "planes_vencidos", "prioridad_alta", "pct_prioridad_alta", "puntajes_faltantes", "ids_control_duplicados", "deficientes_sin_plan"),
  valor = c(nrow(riesgos), nrow(controles),
            conteo(!riesgos$id_riesgo %in% controles$id_riesgo),
            round(100 * conteo(!riesgos$id_riesgo %in% controles$id_riesgo) / nrow(riesgos), 2),
            conteo(controles$evidencia == "No"),
            round(100 * conteo(controles$evidencia == "No") / nrow(controles), 2),
            conteo(controles$resultado_revision == "Deficiente"),
            conteo(controles$estado_plan == "Vencido"),
            conteo(resultado_final$prioridad == "Alta"),
            round(100 * conteo(resultado_final$prioridad == "Alta") / nrow(resultado_final), 2),
            sum(is.na(resultado_final$puntaje_prioridad)),
            sum(duplicated(controles$id_control)),
            conteo(controles$resultado_revision == "Deficiente" & controles$plan_accion != "Si")),
  stringsAsFactors = FALSE
)
prioridades <- data.frame(
  prioridad = c("Alta", "Media", "Baja"),
  cantidad = vapply(c("Alta", "Media", "Baja"), function(x) conteo(resultado_final$prioridad == x), integer(1)),
  row.names = NULL
)
stopifnot(sum(prioridades$cantidad) == nrow(resultado_final))
stopifnot(metricas$valor[metricas$indicador == "puntajes_faltantes"] == 0)
stopifnot(metricas$valor[metricas$indicador == "ids_control_duplicados"] == 0)
stopifnot(metricas$valor[metricas$indicador == "deficientes_sin_plan"] == 0)
cat("\nMONITOREO DEL MVP\n")
print(metricas, row.names = FALSE)
print(prioridades, row.names = FALSE)
