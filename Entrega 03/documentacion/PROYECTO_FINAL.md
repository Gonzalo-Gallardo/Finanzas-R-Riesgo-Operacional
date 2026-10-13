# Proyecto final: revisión y priorización de riesgos y controles
**Finanzas en R — Entrega 03**  
**Autor:** Gonzalo Gallardo

## 1. Descripción de la solución
El problema es la revisión manual y heterogénea de los atributos de riesgos operacionales y de sus controles asociados. El usuario principal es el analista de Riesgo Operacional; los responsables de procesos pueden utilizar las observaciones para regularizar controles. El MVP procesa datos estructurados, calcula criticidad (probabilidad × impacto), relaciona riesgos y controles, identifica alertas y produce una priorización explicable. Se propone ejecutarlo cuando se actualice el universo de controles. El alcance incluye validaciones, matrices y reportes; excluye conexión a sistemas bancarios, gestión transaccional, decisiones automáticas y predicción de pérdidas.

## 2. Planificación del trabajo
La Entrega 01 definió alcance y secuencia: definición del problema → estructura de datos → limpieza/validaciones → reglas y puntuación → pruebas → documentación → propuesta de despliegue → monitoreo. Las primeras cinco fases fueron abordadas en las entregas 01 y 02; esta entrega desarrolla las tres últimas y consolida el resultado. La planificación es referencial, no evidencia de ejecución en producción.

## 3. MVP desarrollado
El script `Entrega 02/riesgo_operacional_mvp.R` contiene 10 riesgos y 12 controles de demostración. Cada riesgo se clasifica por `probabilidad × impacto`: crítico desde 20, alto desde 10, medio desde 5, bajo en los demás casos. La puntuación de prioridad suma al puntaje de riesgo: riesgo crítico +3, sin evidencia +3, revisión no satisfactoria +2, resultado deficiente +3, plan vencido +3, control manual +1. Alta desde 25, Media desde 15, Baja en los demás casos. Son reglas de negocio propuestas, no coeficientes calibrados ni predicciones. El MVP comprueba unicidad de IDs, escalas, relaciones y consistencia de planes. En la ejecución revisada: 10 riesgos, 12 controles; prioridades Alta 2, Media 6, Baja 4. Produce matriz de riesgos, ranking y reporte Quarto HTML.

## 4. Documentación
**Arquitectura lógica:** datos de riesgos/controles → validaciones → asociación → cálculo de criticidad → alertas → puntuación → revisión priorizada → reporte → seguimiento. Véase `DIAGRAMA_FLUJO.md` y `DICCIONARIO_DATOS.md`.

**Limpieza y transformación:** los datos se construyen con tipos y categorías explícitos; se comprueba escala de probabilidad/impacto, duplicados, referencias y planes. Se calculan variables derivadas y se ordenan por puntaje. No existe aún un módulo general para ingerir archivos externos ni imputar faltantes: para datos operativos reales habría que agregar esquema, validación de tipos, control de nulos, registros rechazados y trazabilidad de origen.

**Uso y limitaciones:** el motor de reglas apoya, pero no reemplaza el juicio profesional. Un control automatizado no es necesariamente eficaz; el atributo manual agrega un punto como criterio exploratorio, sujeto a calibración. El conjunto del MVP no contiene riesgos sin controles. El validador auxiliar rechaza ese caso por defecto y puede reportarlo de forma explícita; todavía debe integrarse a una futura ingesta productiva.

**Versionado:** el código se mantiene en GitHub y las dependencias de R se documentan con `renv.lock` en la raíz del proyecto; su configuración local fue verificada mediante `renv::status()`. El reporte se genera con Quarto. El modelo no es predictivo; por eso una ficha tipo model card debe documentar propósito, reglas, datos, validaciones y límites, en vez de métricas predictivas como accuracy.

## 5. Propuesta de despliegue
**Estado actual:** prototipo local y HTML publicado como artefacto. **Despliegue futuro propuesto:** (1) definir propietario de datos y permisos; (2) reemplazar los datos embebidos por CSV o fuente aprobada; (3) ejecutar validaciones de entrada y abortar ante errores críticos; (4) ejecutar el motor con R y dependencias fijadas por `renv`; (5) guardar reporte HTML, base priorizada y bitácora de ejecución en una ubicación controlada; (6) revisión del analista y registro de acciones; (7) versionar cambios y disponer de reversión. Puede iniciarse como tarea programada en un servidor o estación autorizada, sin requerir aplicación web. **No se afirma que exista un despliegue productivo.**

**Seguridad y continuidad:** control de acceso, no almacenar credenciales en GitHub, separar entradas/salidas, evitar datos sensibles en logs, mantener respaldo de versiones y definir responsable de incidentes.

## 6. Propuesta de monitoreo
Se adjunta `codigo/monitoreo_mvp.R` como prueba de concepto que calcula indicadores desde el resultado del MVP. Las métricas propuestas incluyen: total de riesgos y controles, porcentaje de riesgos sin control, controles sin evidencia, controles deficientes, planes vencidos, prioridades altas, registros sin puntuación y duplicados. Se recomienda ejecutar con cada actualización del universo; revisar tendencias mensualmente. **Umbrales propuestos, no validados:** errores críticos de estructura o IDs duplicados = detener ejecución; controles deficientes sin plan = detener/publicar alerta; riesgos sin control >0 = revisión; sin evidencia >0 = seguimiento; variación de prioridad Alta >20% respecto del período anterior = investigar. Las alertas deben distinguir incumplimientos de calidad de datos de hallazgos operacionales.

**Responsables:** analista de RO ejecuta/revisa, dueño de proceso explica y corrige, soporte técnico atiende fallas de ejecución. **Respuesta:** registrar incidencia, validar causa, documentar acción, repetir ejecución y conservar evidencias. **Control de cambios:** probar reglas y umbrales en un conjunto de regresión antes de actualizar la versión.

## Conclusión
El proyecto ofrece una herramienta reproducible y explicable para ordenar la revisión de riesgos y controles. La tercera entrega completa la documentación y plantea cómo desplegar y monitorear el MVP, manteniendo explícita la diferencia entre una demostración funcional y una implementación productiva.


## Verificación técnica de la entrega
Se ejecutaron las pruebas de integración desde la raíz con `source("Entrega 03/codigo/pruebas_entrega03.R")`, sin fallas, y se regeneró `Entrega 03/reporte_final.html` con Quarto. La configuración local de `renv` quedó sincronizada. Para reproducir estos resultados desde GitHub deben publicarse también los archivos de configuración de `renv` en la raíz del repositorio y comprobarse la restauración en otro entorno.

## Validación adicional para una futura ingesta
Se incorpora `codigo/validar_entradas.R` como función auxiliar de control de calidad para fuentes tabulares futuras. `codigo/pruebas_negativas.R` contiene escenarios de rechazo y cobertura. Estas funciones no reemplazan el conjunto embebido del MVP ni se presentan como despliegue productivo; su integración a un flujo de extracción sigue siendo trabajo futuro.
