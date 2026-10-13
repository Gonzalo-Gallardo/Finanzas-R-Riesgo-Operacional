# Diccionario de datos

| Campo | Origen | Definición / regla |
|---|---|---|
| id_riesgo | Riesgos | Identificador único R01–R10 |
| descripcion_riesgo | Riesgos | Descripción textual |
| probabilidad | Riesgos | Entero 1 a 5 |
| impacto | Riesgos | Entero 1 a 5 |
| puntaje_riesgo | Calculado | probabilidad × impacto |
| nivel_riesgo | Calculado | Crítico >=20; Alto >=10; Medio >=5; Bajo restante |
| id_control | Controles | Identificador único C01–C12 |
| descripcion_control | Controles | Descripción textual |
| tipo_control | Controles | Preventivo / Detectivo |
| ejecucion | Controles | Manual / Automatizado |
| frecuencia | Controles | Diaria / Semanal / Mensual / Trimestral |
| evidencia | Controles | Si / No |
| resultado_revision | Controles | Satisfactorio / Con observaciones / Deficiente |
| plan_accion | Controles | Si / No |
| estado_plan | Controles | No aplica / Pendiente / En proceso / Vencido |
| alertas | Calculado | Descripción concatenada de señales |
| puntaje_prioridad | Calculado | Puntaje riesgo + ponderaciones de alertas |
| prioridad | Calculado | Alta >=25; Media >=15; Baja restante |

Los datos de demostración están embebidos en el script de Entrega 02. Para uso operativo se requiere validar exhaustivamente campos, tipos y categorías de la fuente de entrada.
