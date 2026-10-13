# Ejecutar desde la raíz del repositorio: source("Entrega 03/codigo/verificar_publicacion.R")
requeridos <- c(
  "Entrega 01", "Entrega 02/riesgo_operacional_mvp.R",
  "Entrega 03/reporte_final.qmd", "Entrega 03/reporte_final.html",
  "Entrega 03/codigo/pruebas_entrega03.R", "renv.lock", ".Rprofile",
  "renv/activate.R", "renv/settings.json"
)
existe <- file.exists(requeridos) | dir.exists(requeridos)
print(data.frame(ruta = requeridos, presente = existe), row.names = FALSE)
if (!all(existe)) {
  stop("Faltan archivos en la raíz del repositorio: ",
       paste(requeridos[!existe], collapse = ", "))
}
if (!requireNamespace("renv", quietly = TRUE)) {
  stop("renv no está disponible. Active el proyecto y restaure las dependencias.")
}
renv::status()
cat("\nVERIFICACIÓN DE ESTRUCTURA COMPLETADA\n")
