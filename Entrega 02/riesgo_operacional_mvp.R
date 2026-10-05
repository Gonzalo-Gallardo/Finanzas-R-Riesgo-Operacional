# ============================================================
# FINANZAS EN R - ENTREGA 02
# MVP: Revision y priorizacion de riesgos y controles
# Alumno: Gonzalo Gallardo
#
# ============================================================


# ------------------------------------------------------------
# 1. PAQUETES
# ------------------------------------------------------------

paquetes <- c("dplyr", "ggplot2", "stringr")

faltantes <- paquetes[
  !sapply(paquetes, requireNamespace, quietly = TRUE)
]

if (length(faltantes) > 0) {
  install.packages(faltantes)
}

library(dplyr)
library(ggplot2)
library(stringr)


# ------------------------------------------------------------
# 2. BASE SIMULADA DE RIESGOS
# ------------------------------------------------------------

riesgos <- data.frame(
  
  id_riesgo = paste0("R", sprintf("%02d", 1:10)),
  
  descripcion_riesgo = c(
    "Errores en el procesamiento de transacciones",
    "Acceso no autorizado a sistemas",
    "Interrupcion de servicios tecnologicos",
    "Errores en conciliaciones operativas",
    "Incumplimiento de procedimientos internos",
    "Perdida de informacion relevante",
    "Errores en reportes operacionales",
    "Fallas en procesos manuales",
    "Incumplimiento de plazos operativos",
    "Registro incorrecto de operaciones"
  ),
  
  probabilidad = c(4, 3, 5, 3, 2, 4, 2, 5, 3, 4),
  
  impacto = c(5, 5, 4, 3, 4, 5, 3, 3, 2, 4),
  
  stringsAsFactors = FALSE
)


# ------------------------------------------------------------
# 3. CALCULO DEL NIVEL DE RIESGO
# ------------------------------------------------------------

riesgos <- riesgos %>%
  mutate(
    puntaje_riesgo = probabilidad * impacto,
    
    nivel_riesgo = case_when(
      puntaje_riesgo >= 20 ~ "Critico",
      puntaje_riesgo >= 10 ~ "Alto",
      puntaje_riesgo >= 5  ~ "Medio",
      TRUE ~ "Bajo"
    )
  )


# ------------------------------------------------------------
# 4. BASE SIMULADA DE CONTROLES
# ------------------------------------------------------------

controles <- data.frame(
  
  id_control = paste0("C", sprintf("%02d", 1:12)),
  
  id_riesgo = c(
    "R01", "R01", "R02", "R03",
    "R04", "R05", "R06", "R06",
    "R07", "R08", "R09", "R10"
  ),
  
  descripcion_control = c(
    "Revision diaria de transacciones procesadas",
    "Conciliacion de operaciones",
    "Revision periodica de accesos",
    "Monitoreo de disponibilidad de sistemas",
    "Revision de conciliaciones",
    "Revision de cumplimiento de procedimientos",
    "Respaldo periodico de informacion",
    "Validacion de recuperacion de respaldos",
    "Revision de reportes antes de su envio",
    "Validacion de procesos manuales",
    "Seguimiento de plazos operativos",
    "Revision de registros de operaciones"
  ),
  
  tipo_control = c(
    "Detectivo", "Detectivo", "Preventivo", "Detectivo",
    "Detectivo", "Preventivo", "Preventivo", "Detectivo",
    "Preventivo", "Detectivo", "Preventivo", "Detectivo"
  ),
  
  ejecucion = c(
    "Manual", "Manual", "Automatizado", "Automatizado",
    "Manual", "Manual", "Automatizado", "Manual",
    "Manual", "Manual", "Automatizado", "Manual"
  ),
  
  frecuencia = c(
    "Diaria", "Mensual", "Mensual", "Diaria",
    "Mensual", "Trimestral", "Diaria", "Trimestral",
    "Mensual", "Semanal", "Diaria", "Mensual"
  ),
  
  evidencia = c(
    "Si", "Si", "No", "Si",
    "Si", "No", "Si", "No",
    "Si", "Si", "No", "Si"
  ),
  
  resultado_revision = c(
    "Satisfactorio",
    "Con observaciones",
    "Con observaciones",
    "Satisfactorio",
    "Satisfactorio",
    "Con observaciones",
    "Satisfactorio",
    "Deficiente",
    "Satisfactorio",
    "Con observaciones",
    "Deficiente",
    "Satisfactorio"
  ),
  
  plan_accion = c(
    "No", "Si", "Si", "No",
    "No", "Si", "No", "Si",
    "No", "Si", "Si", "No"
  ),
  
  estado_plan = c(
    "No aplica",
    "En proceso",
    "Pendiente",
    "No aplica",
    "No aplica",
    "Pendiente",
    "No aplica",
    "Vencido",
    "No aplica",
    "En proceso",
    "Pendiente",
    "No aplica"
  ),
  
  stringsAsFactors = FALSE
)


# ------------------------------------------------------------
# 5. VALIDACION BASICA DE LOS DATOS
# ------------------------------------------------------------

cat("\n========================================\n")
cat("VALIDACION DE DATOS\n")
cat("========================================\n")

cat("Cantidad de riesgos:", nrow(riesgos), "\n")
cat("Cantidad de controles:", nrow(controles), "\n")

cat(
  "Valores faltantes en riesgos:",
  sum(is.na(riesgos)),
  "\n"
)

cat(
  "Valores faltantes en controles:",
  sum(is.na(controles)),
  "\n"
)

# Validar que probabilidad e impacto esten entre 1 y 5

if (any(!riesgos$probabilidad %in% 1:5)) {
  stop("Existen probabilidades fuera de la escala 1 a 5.")
}

if (any(!riesgos$impacto %in% 1:5)) {
  stop("Existen impactos fuera de la escala 1 a 5.")
}


# ------------------------------------------------------------
# 6. VALIDACION DE ASOCIACION RIESGO - CONTROL
# ------------------------------------------------------------

controles <- controles %>%
  mutate(
    riesgo_valido = id_riesgo %in% riesgos$id_riesgo
  )

if (any(!controles$riesgo_valido)) {
  warning("Existen controles asociados a riesgos inexistentes.")
}


# Riesgos sin controles asociados

riesgos_sin_control <- riesgos %>%
  anti_join(
    controles,
    by = "id_riesgo"
  )

cat(
  "Riesgos sin controles asociados:",
  nrow(riesgos_sin_control),
  "\n"
)


# ------------------------------------------------------------
# 7. UNION DE RIESGOS Y CONTROLES
# ------------------------------------------------------------

base_revision <- riesgos %>%
  left_join(
    controles,
    by = "id_riesgo"
  )


# ------------------------------------------------------------
# 8. GENERACION DE ALERTAS
# ------------------------------------------------------------

base_revision <- base_revision %>%
  mutate(
    
    alerta_riesgo_critico =
      if_else(nivel_riesgo == "Critico", 1, 0),
    
    alerta_sin_evidencia =
      if_else(evidencia == "No", 1, 0),
    
    alerta_revision =
      if_else(
        resultado_revision != "Satisfactorio",
        1,
        0
      ),
    
    alerta_deficiente =
      if_else(
        resultado_revision == "Deficiente",
        1,
        0
      ),
    
    alerta_plan_vencido =
      if_else(estado_plan == "Vencido", 1, 0),
    
    alerta_manual =
      if_else(ejecucion == "Manual", 1, 0)
  )


# ------------------------------------------------------------
# 9. PUNTAJE DE PRIORIDAD
# ------------------------------------------------------------
#
# El nivel de riesgo constituye la base de la priorizacion.
# Se agregan puntos cuando existen condiciones que requieren
# mayor atencion por parte del analista.
#
# ------------------------------------------------------------

base_revision <- base_revision %>%
  mutate(
    
    puntaje_prioridad =
      puntaje_riesgo +
      alerta_riesgo_critico * 3 +
      alerta_sin_evidencia * 3 +
      alerta_revision * 2 +
      alerta_deficiente * 3 +
      alerta_plan_vencido * 3 +
      alerta_manual * 1,
    
    prioridad = case_when(
      puntaje_prioridad >= 25 ~ "Alta",
      puntaje_prioridad >= 15 ~ "Media",
      TRUE ~ "Baja"
    )
  )


# ------------------------------------------------------------
# 10. EXPLICACION DE LAS ALERTAS
# ------------------------------------------------------------

base_revision <- base_revision %>%
  rowwise() %>%
  mutate(
    
    alertas = paste(
      
      c(
        if (alerta_riesgo_critico == 1)
          "Riesgo critico",
        
        if (alerta_sin_evidencia == 1)
          "Control sin evidencia",
        
        if (alerta_revision == 1)
          "Revision con observaciones",
        
        if (alerta_deficiente == 1)
          "Resultado deficiente",
        
        if (alerta_plan_vencido == 1)
          "Plan de accion vencido",
        
        if (alerta_manual == 1)
          "Control manual"
      ),
      
      collapse = "; "
    )
    
  ) %>%
  ungroup()


# Cuando no existen alertas

base_revision$alertas[
  base_revision$alertas == ""
] <- "Sin alertas adicionales"


# ------------------------------------------------------------
# 11. TABLA FINAL PRIORIZADA
# ------------------------------------------------------------

resultado_final <- base_revision %>%
  select(
    id_riesgo,
    descripcion_riesgo,
    probabilidad,
    impacto,
    puntaje_riesgo,
    nivel_riesgo,
    id_control,
    descripcion_control,
    tipo_control,
    ejecucion,
    frecuencia,
    evidencia,
    resultado_revision,
    plan_accion,
    estado_plan,
    alertas,
    puntaje_prioridad,
    prioridad
  ) %>%
  arrange(
    desc(puntaje_prioridad),
    desc(puntaje_riesgo)
  )


cat("\n========================================\n")
cat("RESULTADO FINAL PRIORIZADO\n")
cat("========================================\n")

print(resultado_final)


# ------------------------------------------------------------
# 12. RESUMEN DE PRIORIDADES
# ------------------------------------------------------------

resumen_prioridad <- resultado_final %>%
  count(prioridad) %>%
  arrange(desc(n))

cat("\n========================================\n")
cat("RESUMEN DE PRIORIDADES\n")
cat("========================================\n")

print(resumen_prioridad)


# ------------------------------------------------------------
# 13. RESUMEN DE RIESGOS
# ------------------------------------------------------------

resumen_riesgos <- riesgos %>%
  arrange(desc(puntaje_riesgo))

cat("\n========================================\n")
cat("RIESGOS ORDENADOS POR CRITICIDAD\n")
cat("========================================\n")

print(resumen_riesgos)


# ------------------------------------------------------------
# 14. MATRIZ DE RIESGOS
# ------------------------------------------------------------

matriz_riesgos <- ggplot(
  riesgos,
  aes(
    x = probabilidad,
    y = impacto
  )
) +
  geom_point(
    aes(size = puntaje_riesgo)
  ) +
  geom_text(
    aes(label = id_riesgo),
    vjust = -1
  ) +
  scale_x_continuous(
    breaks = 1:5,
    limits = c(1, 5)
  ) +
  scale_y_continuous(
    breaks = 1:5,
    limits = c(1, 5)
  ) +
  labs(
    title = "Matriz de Riesgos",
    x = "Probabilidad",
    y = "Impacto",
    size = "Nivel de riesgo"
  ) +
  theme_minimal()

print(matriz_riesgos)


# ------------------------------------------------------------
# 15. GRAFICO DE CONTROLES SEGUN PRIORIDAD
# ------------------------------------------------------------

grafico_prioridad <- ggplot(
  resultado_final,
  aes(
    x = reorder(id_control, puntaje_prioridad),
    y = puntaje_prioridad
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Priorizacion de controles para revision",
    subtitle = "Mayor puntaje = mayor prioridad de revision",
    x = "Control",
    y = "Puntaje de prioridad"
  ) +
  theme_minimal()

print(grafico_prioridad)


# ------------------------------------------------------------
# 16. CONTROLES DE PRIORIDAD ALTA
# ------------------------------------------------------------

controles_prioridad_alta <- resultado_final %>%
  filter(prioridad == "Alta") %>%
  select(
    id_riesgo,
    id_control,
    nivel_riesgo,
    resultado_revision,
    evidencia,
    estado_plan,
    puntaje_prioridad,
    alertas
  )

cat("\n========================================\n")
cat("CONTROLES DE PRIORIDAD ALTA\n")
cat("========================================\n")

print(controles_prioridad_alta)


# ------------------------------------------------------------
# 17. VALIDACIONES FINALES DEL MVP
# ------------------------------------------------------------

cat("\n========================================\n")
cat("VALIDACIONES FINALES DEL MVP\n")
cat("========================================\n")

# 1. Identificadores unicos
stopifnot(!anyDuplicated(riesgos$id_riesgo))
stopifnot(!anyDuplicated(controles$id_control))

# 2. Escala y calculo del riesgo
stopifnot(all(riesgos$probabilidad %in% 1:5))
stopifnot(all(riesgos$impacto %in% 1:5))
stopifnot(all(
  riesgos$puntaje_riesgo == riesgos$probabilidad * riesgos$impacto
))

# 3. Asociacion riesgo-control
stopifnot(all(controles$id_riesgo %in% riesgos$id_riesgo))

riesgos_sin_control_validacion <- riesgos %>%
  anti_join(
    controles %>% distinct(id_riesgo),
    by = "id_riesgo"
  )

if (nrow(riesgos_sin_control_validacion) > 0) {
  warning(
    "Existen riesgos sin controles asociados: ",
    paste(riesgos_sin_control_validacion$id_riesgo, collapse = ", ")
  )
}

# 4. Coherencia de planes de accion
planes_inconsistentes <- controles %>%
  filter(
    (plan_accion == "No" & estado_plan != "No aplica") |
      (plan_accion == "Si" & estado_plan == "No aplica")
  )
stopifnot(nrow(planes_inconsistentes) == 0)

deficientes_sin_plan <- controles %>%
  filter(
    resultado_revision == "Deficiente",
    plan_accion != "Si"
  )
stopifnot(nrow(deficientes_sin_plan) == 0)

# 5. Integridad del resultado final
stopifnot(nrow(resultado_final) == nrow(controles))
stopifnot(!any(is.na(resultado_final$puntaje_prioridad)))
stopifnot(all(resultado_final$prioridad %in% c("Alta", "Media", "Baja")))

cat("OK - IDs de riesgos sin duplicados\n")
cat("OK - IDs de controles sin duplicados\n")
cat("OK - Probabilidad e impacto dentro de escala 1 a 5\n")
cat("OK - Puntajes de riesgo correctamente calculados\n")
cat("OK - Controles asociados a riesgos existentes\n")
cat("OK - Coherencia de planes de accion validada\n")
cat("OK - Resultados deficientes cuentan con plan de accion\n")
cat("OK - Puntajes y categorias de prioridad validos\n")


# ------------------------------------------------------------
# 18. RESUMEN FINAL DEL MVP
# ------------------------------------------------------------

cat("\n========================================\n")
cat("MVP EJECUTADO CORRECTAMENTE\n")
cat("========================================\n")
cat("Riesgos analizados:", nrow(riesgos), "\n")
cat("Controles analizados:", nrow(controles), "\n")
cat(
  "Riesgos con controles asociados:",
  length(unique(controles$id_riesgo)),
  "\n"
)
cat("Casos de prioridad Alta:", sum(resultado_final$prioridad == "Alta"), "\n")
cat("Casos de prioridad Media:", sum(resultado_final$prioridad == "Media"), "\n")
cat("Casos de prioridad Baja:", sum(resultado_final$prioridad == "Baja"), "\n")
cat("\nTodas las validaciones del MVP fueron superadas.\n")
