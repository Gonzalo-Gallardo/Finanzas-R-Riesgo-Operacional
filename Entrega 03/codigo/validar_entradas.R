# Validador auxiliar para una futura ingesta tabular; independiente del MVP embebido.
validar_entradas <- function(riesgos, controles, permitir_riesgos_sin_control = FALSE) {
  campos_r <- c("id_riesgo", "probabilidad", "impacto")
  campos_c <- c("id_control", "id_riesgo")
  if (!is.data.frame(riesgos) || !is.data.frame(controles) ||
      !all(campos_r %in% names(riesgos)) || !all(campos_c %in% names(controles))) stop("Esquema de entrada inválido")
  if (!is.logical(permitir_riesgos_sin_control) || length(permitir_riesgos_sin_control) != 1L ||
      is.na(permitir_riesgos_sin_control)) stop("Parámetro de cobertura inválido")
  if (!nrow(riesgos) || !nrow(controles)) stop("Universo vacío")
  if (anyNA(riesgos[, campos_r, drop = FALSE]) || anyNA(controles[, campos_c, drop = FALSE])) stop("Datos obligatorios faltantes")
  if (!is.character(riesgos$id_riesgo) || !is.character(controles$id_control) ||
      !is.character(controles$id_riesgo)) stop("Los identificadores deben ser texto")
  if (any(!nzchar(trimws(riesgos$id_riesgo))) || any(!nzchar(trimws(controles$id_control))) ||
      any(!nzchar(trimws(controles$id_riesgo)))) stop("Identificadores vacíos")
  if (anyDuplicated(riesgos$id_riesgo) || anyDuplicated(controles$id_control)) stop("IDs duplicados")
  for (campo in c("probabilidad", "impacto")) {
    x <- riesgos[[campo]]
    if (!is.numeric(x) || any(!is.finite(x)) || any(x < 1 | x > 5 | x != floor(x)))
      stop("Probabilidad e impacto deben ser enteros de 1 a 5")
  }
  if (!all(controles$id_riesgo %in% riesgos$id_riesgo)) stop("Control asociado a riesgo inexistente")
  # Los campos del plan son opcionales en el esquema auxiliar. Si se suministran,
  # se validan conjuntamente; el MVP original conserva sus propias reglas.
  campos_plan <- c("resultado_revision", "plan_accion")
  if (any(campos_plan %in% names(controles))) {
    if (!all(campos_plan %in% names(controles))) stop("Faltan campos de revisión o plan de acción")
    if (anyNA(controles[, campos_plan, drop = FALSE])) stop("Datos del plan faltantes")
    revision <- trimws(as.character(controles$resultado_revision))
    plan <- trimws(as.character(controles$plan_accion))
    if (any(!revision %in% c("Satisfactorio", "Con observaciones", "Deficiente")) ||
        any(!plan %in% c("Si", "Sí", "No"))) stop("Categoría de revisión o plan inválida")
    if (any(revision == "Deficiente" & plan == "No")) stop("Control deficiente sin plan de acción")
  }
  sin_control <- setdiff(riesgos$id_riesgo, controles$id_riesgo)
  if (length(sin_control) && !permitir_riesgos_sin_control) stop("Existen riesgos sin controles")
  invisible(list(valido = TRUE, riesgos_sin_control = sin_control))
}
