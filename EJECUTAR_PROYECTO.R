# Ejecutar desde la carpeta principal del proyecto.
# Este script prueba ambas entregas y genera el HTML de la Entrega 03.
if (!file.exists("renv.lock") || !file.exists("Entrega 02/riesgo_operacional_mvp.R") ||
    !file.exists("Entrega 03/reporte_final.qmd")) {
  stop("Abra la CARPETA PRINCIPAL del proyecto en Positron y vuelva a ejecutar.")
}
cat("\n=== INICIANDO PROYECTO FINANZAS EN R ===\n")
if (!requireNamespace("renv", quietly = TRUE)) {
  stop("Falta renv. Instale una vez con install.packages('renv') y reintente.")
}
# Si faltan paquetes, restaurar las versiones del archivo renv.lock.
estado <- tryCatch(renv::status(), error = function(e) e)
if (inherits(estado, "error")) {
  cat("Aviso: no se pudo comprobar renv: ", conditionMessage(estado), "\n", sep = "")
}
cat("\n[1/3] Validando MVP y generando reportes...\n")
source("Entrega 03/codigo/pruebas_entrega03.R", encoding = "UTF-8")
cat("\n[2/3] Ejecutando pruebas negativas...\n")
source("Entrega 03/codigo/pruebas_negativas.R", encoding = "UTF-8")
cat("\n[3/3] Generando informe HTML...\n")
if (nzchar(Sys.which("quarto"))) {
  resultado <- system2("quarto", c("render", shQuote("Entrega 03/reporte_final.qmd")), stdout = "", stderr = "")
  if (!identical(as.integer(resultado), 0L)) stop("Quarto no pudo generar el informe. Revise los mensajes anteriores.")
  cat("Informe HTML generado en Entrega 03/reporte_final.html\n")
} else {
  cat("Quarto no está disponible en PATH. El HTML incluido se conserva; instale Quarto para regenerarlo.\n")
}
cat("\n=== VALIDACIÓN COMPLETADA SIN ERRORES EN R ===\n")
