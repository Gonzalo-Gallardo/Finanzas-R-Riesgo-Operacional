# Pruebas aisladas: no modifican los datos originales ni generan reportes.
source("Entrega 03/codigo/validar_entradas.R", encoding = "UTF-8")
r <- data.frame(id_riesgo = c("R1", "R2"), probabilidad = c(3, 4), impacto = c(4, 5))
c <- data.frame(id_control = c("C1", "C2"), id_riesgo = c("R1", "R2"))
stopifnot(isTRUE(validar_entradas(r, c)$valido))
debe_fallar <- function(expr) inherits(tryCatch({force(expr); NULL}, error = function(e) e), "error")
r_dup <- r; r_dup$id_riesgo[2] <- "R1"
c_dup <- c; c_dup$id_control[2] <- "C1"
r_escala <- r; r_escala$probabilidad[1] <- 6
r_decimal <- r; r_decimal$impacto[1] <- 2.5
c_huerfano <- c; c_huerfano$id_riesgo[2] <- "R999"
c_sin_cobertura <- c[1, , drop = FALSE]
c_planes <- c; c_planes$resultado_revision <- c("Satisfactorio", "Deficiente")
c_planes$plan_accion <- c("No", "No")
stopifnot(
  debe_fallar(validar_entradas(r_dup, c)),
  debe_fallar(validar_entradas(r, c_dup)),
  debe_fallar(validar_entradas(r_escala, c)),
  debe_fallar(validar_entradas(r_decimal, c)),
  debe_fallar(validar_entradas(r, c_huerfano)),
  debe_fallar(validar_entradas(r, c_sin_cobertura)),
  identical(validar_entradas(r, c_sin_cobertura, TRUE)$riesgos_sin_control, "R2"),
  debe_fallar(validar_entradas(r, c_planes))
)
c_planes$plan_accion[2] <- "Si"
stopifnot(isTRUE(validar_entradas(r, c_planes)$valido))
r_na <- r; r_na$id_riesgo[1] <- NA_character_
r_blanco <- r; r_blanco$id_riesgo[1] <- " "
stopifnot(debe_fallar(validar_entradas(r_na, c)), debe_fallar(validar_entradas(r_blanco, c)))
cat("PRUEBAS NEGATIVAS DEL VALIDADOR AUXILIAR: SUPERADAS\n")
